import SwiftUI

// MARK: - Modelos de Datos
struct Variable: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var value: Bool
}

enum ComponentType: String, CaseIterable, Equatable {
    case input = "Entrada"
    case output = "Salida"
    case andGate = "AND"
    case orGate = "OR"
    case notGate = "NOT"
}

struct CircuitComponent: Identifiable, Equatable {
    let id = UUID()
    let type: ComponentType
    let name: String
    var position: CGPoint
    var connectedTo: [UUID] = []
    var value: Bool = false
    
    static func == (lhs: CircuitComponent, rhs: CircuitComponent) -> Bool {
        return lhs.id == rhs.id &&
               lhs.type == rhs.type &&
               lhs.name == rhs.name &&
               lhs.position == rhs.position &&
               lhs.connectedTo == rhs.connectedTo &&
               lhs.value == rhs.value
    }
}

// MARK: - Vistas de Componentes
struct ConnectionView: View {
    let from: CGPoint
    let to: CGPoint
    let isActive: Bool
    
    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(isActive ? Color.green : Color.gray, lineWidth: 2)
    }
}

struct CircuitComponentView: View {
    @Environment(\.colorScheme) var colorScheme
    let component: CircuitComponent
    let isSelected: Bool
    let onTap: () -> Void
    let onDrag: (CGPoint) -> Void
    let onConnectionStart: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Group {
            switch component.type {
            case .input:
                inputView
            case .output:
                outputView
            case .andGate:
                andGateView
            case .orGate:
                orGateView
            case .notGate:
                notGateView
            }
        }
        .gesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    onDrag(value.location)
                }
        )
        .onTapGesture(perform: onTap)
        .contextMenu {
            Button(action: onConnectionStart) {
                Label("Conectar desde aquí", systemImage: "arrow.right")
            }
            
            if component.type != .input && component.type != .output {
                Button(role: .destructive, action: onDelete) {
                    Label("Eliminar", systemImage: "trash")
                }
            }
        }
    }
    
    private var inputView: some View {
        ZStack {
            Circle()
                .fill(component.value ? Color.green : Color.blue)
                .frame(width: 40, height: 40)
            
            VStack(spacing: 2) {
                Text(component.name)
                    .foregroundColor(.white)
                    .font(.caption)
                Text(component.value ? "1" : "0")
                    .foregroundColor(.white)
                    .font(.caption2)
            }
        }
        .overlay(
            Circle()
                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
        )
    }
    
    private var outputView: some View {
        ZStack {
            Circle()
                .fill(component.value ? Color.green : Color.red)
                .frame(width: 40, height: 40)
            
            VStack(spacing: 2) {
                Text("OUT")
                    .foregroundColor(.white)
                    .font(.caption)
                Text(component.value ? "1" : "0")
                    .foregroundColor(.white)
                    .font(.caption2)
            }
        }
        .overlay(
            Circle()
                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
        )
    }
    
    private var andGateView: some View {
        VStack(spacing: 2) {
            Text("AND")
                .font(.system(size: 12, weight: .bold))
            Text(component.value ? "1" : "0")
                .font(.system(size: 10))
        }
        .frame(width: 50, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(component.value ? Color.green.opacity(0.3) : (colorScheme == .dark ? Color.black : Color.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.yellow : Color.orange, lineWidth: 2)
                )
        )
    }
    
    private var orGateView: some View {
        VStack(spacing: 2) {
            Text("OR")
                .font(.system(size: 12, weight: .bold))
            Text(component.value ? "1" : "0")
                .font(.system(size: 10))
        }
        .frame(width: 50, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(component.value ? Color.green.opacity(0.3) : (colorScheme == .dark ? Color.black : Color.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.yellow : Color.purple, lineWidth: 2)
                )
        )
    }
    
    private var notGateView: some View {
        ZStack {
            Circle()
                .fill(component.value ? Color.green.opacity(0.3) : (colorScheme == .dark ? Color.black : Color.white))
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.yellow : Color.green, lineWidth: 2)
                )
            
            VStack(spacing: 2) {
                Text("NOT")
                    .font(.system(size: 10, weight: .bold))
                Text(component.value ? "1" : "0")
                    .font(.system(size: 8))
            }
        }
    }
}

// MARK: - CircuitCanvas
struct CircuitCanvas: View {
    @Binding var components: [CircuitComponent]
    @Binding var selectedComponent: UUID?
    @Binding var connectionStart: UUID?
    @Binding var tempConnection: CGPoint?
    @Binding var outputValue: Bool
    @Binding var kmapValues: [[Bool]]
    @Binding var booleanEquation: String
    @Binding var variables: [Variable]
    
    @State private var canvasSize: CGSize = CGSize(width: 1500, height: 1000)
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo con cuadrícula
                gridBackground
                    .frame(width: canvasSize.width, height: canvasSize.height)
                
                // Contenido del circuito
                circuitContent
                    .frame(width: canvasSize.width, height: canvasSize.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation
                        offset.width = lastOffset.width + translation.width / scale
                        offset.height = lastOffset.height + translation.height / scale
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let newScale = lastScale * value
                        scale = max(min(newScale, 3.0), 0.5)
                    }
                    .onEnded { _ in
                        lastScale = scale
                    }
            )
            .onTapGesture {
                selectedComponent = nil
            }
        }
    }
    
    private var gridBackground: some View {
        Path { path in
            let gridSize: CGFloat = 20
            let rows = Int(canvasSize.height / gridSize)
            let cols = Int(canvasSize.width / gridSize)
            
            // Líneas verticales
            for col in 0...cols {
                let x = CGFloat(col) * gridSize
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: canvasSize.height))
            }
            
            // Líneas horizontales
            for row in 0...rows {
                let y = CGFloat(row) * gridSize
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: canvasSize.width, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
    }
    
    private var circuitContent: some View {
        ZStack {
            // Conexiones entre componentes
            ForEach(components) { component in
                ForEach(component.connectedTo, id: \.self) { connectedId in
                    if let connectedComponent = components.first(where: { $0.id == connectedId }) {
                        ConnectionView(
                            from: connectedComponent.position,
                            to: component.position,
                            isActive: connectedComponent.value
                        )
                    }
                }
            }
            
            // Conexión temporal durante el arrastre
            if let startId = connectionStart,
               let startComponent = components.first(where: { $0.id == startId }),
               let endPoint = tempConnection {
                ConnectionView(
                    from: startComponent.position,
                    to: endPoint,
                    isActive: false
                )
            }
            
            // Componentes del circuito
            ForEach(components) { component in
                CircuitComponentView(
                    component: component,
                    isSelected: selectedComponent == component.id,
                    onTap: {
                        handleTap(component: component)
                    },
                    onDrag: { location in
                        handleDrag(component: component, location: location)
                    },
                    onConnectionStart: {
                        connectionStart = component.id
                        tempConnection = component.position
                    },
                    onDelete: {
                        deleteComponent(component.id)
                    }
                )
                .position(component.position)
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if let startId = connectionStart {
                        tempConnection = value.location
                    }
                }
                .onEnded { value in
                    if let startId = connectionStart {
                        if let endComponent = components.first(where: {
                            let distance = hypot($0.position.x - value.location.x, $0.position.y - value.location.y)
                            return distance < 30 && $0.id != startId
                        }) {
                            connectComponents(from: startId, to: endComponent.id)
                        }
                        tempConnection = nil
                        connectionStart = nil
                    }
                }
        )
    }
    
    // Funciones de manejo de interacción
    private func handleTap(component: CircuitComponent) {
        if connectionStart == nil {
            selectedComponent = component.id
            if component.type == .input, let index = components.firstIndex(where: { $0.id == component.id }) {
                components[index].value.toggle()
                updateVariable(named: component.name, value: components[index].value)
                updateAllRepresentations()
            }
        }
    }
    
    private func handleDrag(component: CircuitComponent, location: CGPoint) {
        if selectedComponent == component.id {
            if let index = components.firstIndex(where: { $0.id == component.id }) {
                components[index].position = location
            }
        }
    }
    
    private func updateVariable(named name: String, value: Bool) {
        if let index = variables.firstIndex(where: { $0.name == name }) {
            variables[index].value = value
        }
    }
    
    private func deleteComponent(_ id: UUID) {
        components.removeAll { $0.id == id }
        for i in components.indices {
            components[i].connectedTo.removeAll { $0 == id }
        }
        updateAllRepresentations()
    }
    
    private func connectComponents(from startId: UUID, to endId: UUID) {
        guard let startComponent = components.first(where: { $0.id == startId }),
              let endIndex = components.firstIndex(where: { $0.id == endId }) else { return }
        
        if isValidConnection(from: startComponent, to: components[endIndex]) {
            components[endIndex].connectedTo.append(startId)
            updateAllRepresentations()
        }
    }
    
    private func isValidConnection(from: CircuitComponent, to: CircuitComponent) -> Bool {
        // No se puede conectar a una entrada
        if to.type == .input { return false }
        
        // No se pueden crear ciclos
        if createsCycle(start: from.id, end: to.id) { return false }
        
        // Reglas específicas por tipo de componente
        switch to.type {
        case .andGate, .orGate:
            return to.connectedTo.count < 2 // Máximo 2 entradas
        case .notGate:
            return to.connectedTo.isEmpty // Solo 1 entrada
        case .output:
            return to.connectedTo.isEmpty // Solo 1 entrada
        default:
            return true
        }
    }
    
    private func createsCycle(start: UUID, end: UUID) -> Bool {
        var visited = Set<UUID>()
        var queue = [end]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            if current == start { return true }
            
            if !visited.contains(current), let component = components.first(where: { $0.id == current }) {
                visited.insert(current)
                queue.append(contentsOf: component.connectedTo)
            }
        }
        return false
    }
    
    // Actualizar todas las representaciones
    private func updateAllRepresentations() {
        evaluateCircuit()
        updateKmapFromCircuit()
        updateEquationFromCircuit()
    }
    
    // Evaluación del circuito
    private func evaluateCircuit() {
        resetComponentValues()
        let evaluationOrder = getEvaluationOrder()
        
        for componentId in evaluationOrder {
            guard let index = components.firstIndex(where: { $0.id == componentId }) else { continue }
            
            switch components[index].type {
            case .input:
                // Los valores de entrada se mantienen como están
                continue
                
            case .notGate:
                if let inputId = components[index].connectedTo.first,
                   let input = components.first(where: { $0.id == inputId }) {
                    components[index].value = !input.value
                }
                
            case .andGate:
                let inputs = components[index].connectedTo.compactMap { id in
                    components.first { $0.id == id }?.value
                }
                components[index].value = inputs.allSatisfy { $0 } && !inputs.isEmpty
                
            case .orGate:
                let inputs = components[index].connectedTo.compactMap { id in
                    components.first { $0.id == id }?.value
                }
                components[index].value = inputs.contains(true)
                
            case .output:
                if let inputId = components[index].connectedTo.first,
                   let input = components.first(where: { $0.id == inputId }) {
                    components[index].value = input.value
                    outputValue = input.value
                }
            }
        }
    }
    
    private func resetComponentValues() {
        for i in components.indices {
            if components[i].type != .input {
                components[i].value = false
            }
        }
    }
    
    private func getEvaluationOrder() -> [UUID] {
        var visited = Set<UUID>()
        var order: [UUID] = []
        
        func visit(_ componentId: UUID) {
            if !visited.contains(componentId) {
                visited.insert(componentId)
                if let component = components.first(where: { $0.id == componentId }) {
                    for inputId in component.connectedTo {
                        visit(inputId)
                    }
                }
                order.append(componentId)
            }
        }
        
        // Empezar por las salidas y compuertas OR
        for component in components {
            if component.type == .output || component.type == .orGate {
                visit(component.id)
            }
        }
        
        return order
    }
    
    private func updateKmapFromCircuit() {
        // Obtener las variables de entrada (A, B, C)
        let inputNames = ["A", "B", "C"]
        let inputComponents = components.filter { inputNames.contains($0.name) && $0.type == .input }
        
        guard inputComponents.count >= 2 else {
            kmapValues = [[false, false], [false, false]]
            return
        }
        
        // Para 3 variables (A, B, C)
        if inputComponents.count >= 3 {
            kmapValues = [
                [false, false, false, false],
                [false, false, false, false]
            ]
            
            // Probar todas las combinaciones posibles
            for a in [false, true] {
                for b in [false, true] {
                    for c in [false, true] {
                        // Establecer los valores de entrada
                        for variable in inputComponents {
                            if let index = components.firstIndex(where: { $0.id == variable.id }) {
                                if variable.name == "A" { components[index].value = a }
                                if variable.name == "B" { components[index].value = b }
                                if variable.name == "C" { components[index].value = c }
                            }
                        }
                        
                        // Evaluar el circuito con estos valores
                        evaluateCircuit()
                        
                        // Determinar posición en el mapa K
                        let row = a ? 1 : 0
                        let col: Int
                        switch (b, c) {
                        case (false, false): col = 0
                        case (false, true): col = 1
                        case (true, true): col = 2
                        case (true, false): col = 3
                        }
                        
                        // Actualizar el mapa K
                        kmapValues[row][col] = outputValue
                    }
                }
            }
        } else {
            // Para 2 variables (A, B)
            kmapValues = [
                [false, false],
                [false, false]
            ]
            
            for a in [false, true] {
                for b in [false, true] {
                    // Establecer los valores de entrada
                    for variable in inputComponents {
                        if let index = components.firstIndex(where: { $0.id == variable.id }) {
                            if variable.name == "A" { components[index].value = a }
                            if variable.name == "B" { components[index].value = b }
                        }
                    }
                    
                    // Evaluar el circuito
                    evaluateCircuit()
                    
                    // Actualizar el mapa K
                    let row = a ? 1 : 0
                    let col = b ? 1 : 0
                    kmapValues[row][col] = outputValue
                }
            }
        }
        
        // Restaurar valores originales de las entradas
        for variable in inputComponents {
            if let index = components.firstIndex(where: { $0.id == variable.id }) {
                components[index].value = variable.value
            }
        }
        
        // Evaluar el circuito con los valores originales
        evaluateCircuit()
    }
    
    private func updateEquationFromCircuit() {
        guard let output = components.first(where: { $0.type == .output }) else {
            booleanEquation = "f = 0"
            return
        }
        
        var equation = "f = "
        var terms: [String] = []
        
        for inputId in output.connectedTo {
            if let gate = components.first(where: { $0.id == inputId }) {
                terms.append(termForComponent(gate))
            }
        }
        
        if terms.isEmpty {
            booleanEquation = "f = 0"
        } else {
            booleanEquation = equation + terms.joined(separator: " + ")
        }
    }
    
    private func termForComponent(_ component: CircuitComponent) -> String {
        switch component.type {
        case .input:
            return component.value ? component.name : "\(component.name)'"
            
        case .notGate:
            if let inputId = component.connectedTo.first,
               let input = components.first(where: { $0.id == inputId }) {
                return "\(input.name)'"
            }
            return ""
            
        case .andGate:
            var andTerms: [String] = []
            for inputId in component.connectedTo {
                if let input = components.first(where: { $0.id == inputId }) {
                    andTerms.append(input.value ? input.name : "\(input.name)'")
                }
            }
            return andTerms.joined(separator: "·")
            
        case .orGate:
            var orTerms: [String] = []
            for inputId in component.connectedTo {
                if let input = components.first(where: { $0.id == inputId }) {
                    orTerms.append(input.value ? input.name : "\(input.name)'")
                }
            }
            return "(\(orTerms.joined(separator: " + ")))"
            
        default:
            return ""
        }
    }
}

// MARK: - Vista Principal
struct DigitalLogicView: View {
    enum InputMode: String, CaseIterable {
        case karnaugh = "Mapa K"
        case equation = "Ecuación"
        case circuit = "Circuito"
    }
    
    @State private var inputMode: InputMode = .circuit
    @State private var variables: [Variable] = [
        Variable(name: "A", value: false),
        Variable(name: "B", value: false),
        Variable(name: "C", value: false)
    ]
    
    @State private var kmapValues: [[Bool]] = [
        [false, false, false, false],
        [false, false, false, false]
    ]
    
    @State private var booleanEquation = "f = "
    @State private var circuitComponents: [CircuitComponent] = []
    @State private var outputValue: Bool = false
    @State private var selectedComponent: UUID? = nil
    @State private var connectionStart: UUID? = nil
    @State private var tempConnection: CGPoint? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    modePicker
                    editorSection
                    circuitMiniView
                    representationsSection
                    outputSection
                    variablesPanel
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitle("Simulador Lógico", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: resetAll) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reiniciar")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            // Crear entradas iniciales si no existen
            if !circuitComponents.contains(where: { $0.name == "A" && $0.type == .input }) {
                circuitComponents.append(CircuitComponent(
                    type: .input,
                    name: "A",
                    position: CGPoint(x: 200, y: 100)
                ))
            }
            if !circuitComponents.contains(where: { $0.name == "B" && $0.type == .input }) {
                circuitComponents.append(CircuitComponent(
                    type: .input,
                    name: "B",
                    position: CGPoint(x: 200, y: 200)
                ))
            }
            if !circuitComponents.contains(where: { $0.name == "C" && $0.type == .input }) {
                circuitComponents.append(CircuitComponent(
                    type: .input,
                    name: "C",
                    position: CGPoint(x: 200, y: 300)
                ))
            }
        }
    }
    
    // MARK: - Componentes UI
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Simulador de Circuitos Lógicos")
                .font(.largeTitle).bold()
                .foregroundColor(.blue)
            
            Text("Diseña circuitos digitales y visualiza sus representaciones")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var modePicker: some View {
        Picker("Modo", selection: $inputMode) {
            ForEach(InputMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 8)
    }
    
    private var editorSection: some View {
        Group {
            switch inputMode {
            case .karnaugh:
                karnaughEditor
            case .equation:
                equationEditor
            case .circuit:
                circuitEditor
            }
        }
        .cardStyle()
    }
    
    private var karnaughEditor: some View {
        VStack {
            Text("Editor de Mapa de Karnaugh")
                .font(.headline)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 60, height: 30)
                    
                    ForEach(["B'C'", "B'C", "BC", "BC'"], id: \.self) { header in
                        Text(header)
                            .font(.caption)
                            .frame(width: 60, height: 30)
                    }
                }
                
                ForEach(0..<2, id: \.self) { row in
                    HStack(spacing: 0) {
                        Text(row == 0 ? "A'" : "A")
                            .font(.caption)
                            .frame(width: 60, height: 60)
                        
                        ForEach(0..<4, id: \.self) { col in
                            Button(action: {
                                kmapValues[row][col].toggle()
                                updateFromKmap()
                            }) {
                                Text(kmapValues[row][col] ? "1" : "0")
                                    .frame(width: 60, height: 60)
                                    .background(kmapValues[row][col] ? Color.green.opacity(0.3) : Color(.systemBackground))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            
            HStack {
                Button("Todos 0") {
                    kmapValues = [
                        [false, false, false, false],
                        [false, false, false, false]
                    ]
                    updateFromKmap()
                }
                
                Button("Todos 1") {
                    kmapValues = [
                        [true, true, true, true],
                        [true, true, true, true]
                    ]
                    updateFromKmap()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private func updateFromKmap() {
        booleanEquation = simplifyKmap()
        generateCircuitFromKmap()
    }
    
    private func simplifyKmap() -> String {
        // Implementación simplificada del algoritmo de Quine-McCluskey
        var terms: [String] = []
        
        // Grupos de 4 unos
        if kmapValues[0][0] && kmapValues[0][1] && kmapValues[0][2] && kmapValues[0][3] {
            terms.append("A'")
        }
        if kmapValues[1][0] && kmapValues[1][1] && kmapValues[1][2] && kmapValues[1][3] {
            terms.append("A")
        }
        
        // Grupos de 2 unos adyacentes
        if kmapValues[0][0] && kmapValues[0][1] {
            terms.append("A'B'")
        }
        if kmapValues[0][1] && kmapValues[0][2] {
            terms.append("A'C")
        }
        if kmapValues[0][2] && kmapValues[0][3] {
            terms.append("A'B")
        }
        if kmapValues[0][0] && kmapValues[0][3] {
            terms.append("A'C'")
        }
        
        if kmapValues[1][0] && kmapValues[1][1] {
            terms.append("AB'")
        }
        if kmapValues[1][1] && kmapValues[1][2] {
            terms.append("AC")
        }
        if kmapValues[1][2] && kmapValues[1][3] {
            terms.append("AB")
        }
        if kmapValues[1][0] && kmapValues[1][3] {
            terms.append("AC'")
        }
        
        // Unos individuales no cubiertos por grupos
        for row in 0..<2 {
            for col in 0..<4 {
                if kmapValues[row][col] {
                    let a = row == 1 ? "A" : "A'"
                    let bc: String
                    switch col {
                    case 0: bc = "B'C'"
                    case 1: bc = "B'C"
                    case 2: bc = "BC"
                    case 3: bc = "BC'"
                    default: bc = ""
                    }
                    if !terms.contains(where: { $0.contains(a) || $0.contains(bc) }) {
                        terms.append("\(a)\(bc)")
                    }
                }
            }
        }
        
        return terms.isEmpty ? "0" : terms.joined(separator: " + ")
    }
    
    private func generateCircuitFromKmap() {
        // Limpiar componentes existentes (excepto entradas)
        circuitComponents.removeAll { $0.type != .input }
        
        // Asegurar que tenemos entradas A, B, C
        let inputNames = ["A", "B", "C"]
        for name in inputNames {
            if !circuitComponents.contains(where: { $0.name == name && $0.type == .input }) {
                let newInput = CircuitComponent(
                    type: .input,
                    name: name,
                    position: CGPoint(x: 100, y: 100 + CGFloat(inputNames.firstIndex(of: name)! * 100))
                )
                circuitComponents.append(newInput)
            }
        }
        
        // Crear compuertas basadas en la ecuación simplificada
        let equation = simplifyKmap()
        let terms = equation.components(separatedBy: " + ")
        
        var andGates: [CircuitComponent] = []
        var yPosition: CGFloat = 200
        
        for term in terms {
            if term == "0" {
                continue
            }
            
            // Crear compuerta AND para cada término
            let andGate = CircuitComponent(
                type: .andGate,
                name: "AND\(andGates.count + 1)",
                position: CGPoint(x: 300, y: yPosition)
            )
            circuitComponents.append(andGate)
            andGates.append(andGate)
            yPosition += 80
            
            // Conectar entradas a la compuerta AND
            if term.contains("A'") {
                if let inputA = circuitComponents.first(where: { $0.name == "A" }) {
                    let notGate = CircuitComponent(
                        type: .notGate,
                        name: "NOT_A",
                        position: CGPoint(x: 200, y: inputA.position.y + 50)
                    )
                    if !circuitComponents.contains(where: { $0.id == notGate.id }) {
                        circuitComponents.append(notGate)
                        connectComponents(from: inputA.id, to: notGate.id)
                    }
                    connectComponents(from: notGate.id, to: andGate.id)
                }
            } else if term.contains("A") {
                if let inputA = circuitComponents.first(where: { $0.name == "A" }) {
                    connectComponents(from: inputA.id, to: andGate.id)
                }
            }
            
            // Conectar B y C de manera similar
            if term.contains("B'") {
                if let inputB = circuitComponents.first(where: { $0.name == "B" }) {
                    let notGate = CircuitComponent(
                        type: .notGate,
                        name: "NOT_B",
                        position: CGPoint(x: 200, y: inputB.position.y + 50)
                    )
                    if !circuitComponents.contains(where: { $0.id == notGate.id }) {
                        circuitComponents.append(notGate)
                        connectComponents(from: inputB.id, to: notGate.id)
                    }
                    connectComponents(from: notGate.id, to: andGate.id)
                }
            } else if term.contains("B") {
                if let inputB = circuitComponents.first(where: { $0.name == "B" }) {
                    connectComponents(from: inputB.id, to: andGate.id)
                }
            }
            
            if term.contains("C'") {
                if let inputC = circuitComponents.first(where: { $0.name == "C" }) {
                    let notGate = CircuitComponent(
                        type: .notGate,
                        name: "NOT_C",
                        position: CGPoint(x: 200, y: inputC.position.y + 50)
                    )
                    if !circuitComponents.contains(where: { $0.id == notGate.id }) {
                        circuitComponents.append(notGate)
                        connectComponents(from: inputC.id, to: notGate.id)
                    }
                    connectComponents(from: notGate.id, to: andGate.id)
                }
            } else if term.contains("C") {
                if let inputC = circuitComponents.first(where: { $0.name == "C" }) {
                    connectComponents(from: inputC.id, to: andGate.id)
                }
            }
        }
        
        // Crear compuerta OR final si hay múltiples términos
        if andGates.count > 1 {
            let orGate = CircuitComponent(
                type: .orGate,
                name: "OR1",
                position: CGPoint(x: 500, y: 300)
            )
            circuitComponents.append(orGate)
            
            for andGate in andGates {
                connectComponents(from: andGate.id, to: orGate.id)
            }
            
            // Crear salida
            let output = CircuitComponent(
                type: .output,
                name: "OUT",
                position: CGPoint(x: 700, y: 300)
            )
            circuitComponents.append(output)
            connectComponents(from: orGate.id, to: output.id)
        } else if let andGate = andGates.first {
            // Solo un término - conectar directamente a la salida
            let output = CircuitComponent(
                type: .output,
                name: "OUT",
                position: CGPoint(x: 500, y: 300)
            )
            circuitComponents.append(output)
            connectComponents(from: andGate.id, to: output.id)
        } else {
            // Ningún término (siempre 0)
            let output = CircuitComponent(
                type: .output,
                name: "OUT",
                position: CGPoint(x: 300, y: 300),
                value: false
            )
            circuitComponents.append(output)
        }
        
        // Actualizar variables
        for variable in variables {
            if let component = circuitComponents.first(where: { $0.name == variable.name && $0.type == .input }) {
                if let index = variables.firstIndex(where: { $0.name == variable.name }) {
                    variables[index].value = component.value
                }
            }
        }
    }
    
    private func connectComponents(from: UUID, to: UUID) {
        guard let toIndex = circuitComponents.firstIndex(where: { $0.id == to }) else { return }
        
        // Verificar que no sea una conexión duplicada
        if !circuitComponents[toIndex].connectedTo.contains(from) {
            circuitComponents[toIndex].connectedTo.append(from)
        }
        
        // Evaluar el circuito actualizado
        evaluateCircuit()
    }
    
    private var equationEditor: some View {
        VStack {
            Text("Editor de Ecuación")
                .font(.headline)
            
            HStack {
                Text("f =")
                    .font(.title)
                
                TextField("A·B + A'·C", text: $booleanEquation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(.body, design: .monospaced))
                    .onChange(of: booleanEquation) { newValue in
                        parseEquation(newValue)
                    }
            }
            
            HStack {
                ForEach(["A", "B", "C", "'", "+", "·", "(", ")"], id: \.self) { symbol in
                    Button(action: {
                        booleanEquation += symbol
                    }) {
                        Text(symbol)
                            .frame(width: 40, height: 40)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
    }
    
    private func parseEquation(_ equation: String) {
        // Implementación simplificada - en una app real necesitarías un parser más robusto
        let cleanedEquation = equation.replacingOccurrences(of: " ", with: "")
        
        // Si la ecuación está vacía o es "f=0", limpiar el mapa K
        if cleanedEquation.isEmpty || cleanedEquation == "f=0" {
            kmapValues = [
                [false, false, false, false],
                [false, false, false, false]
            ]
            generateCircuitFromKmap()
            return
        }
        
        // Extraer términos después de "f="
        let termsString = cleanedEquation.replacingOccurrences(of: "f=", with: "")
        let terms = termsString.components(separatedBy: "+")
        
        // Limpiar el mapa K
        kmapValues = [
            [false, false, false, false],
            [false, false, false, false]
        ]
        
        // Para cada término, marcar las celdas correspondientes en el mapa K
        for term in terms {
            let cleanedTerm = term.replacingOccurrences(of: "·", with: "")
            
            var a: Bool? = nil
            var b: Bool? = nil
            var c: Bool? = nil
            
            if cleanedTerm.contains("A'") {
                a = false
            } else if cleanedTerm.contains("A") {
                a = true
            }
            
            if cleanedTerm.contains("B'") {
                b = false
            } else if cleanedTerm.contains("B") {
                b = true
            }
            
            if cleanedTerm.contains("C'") {
                c = false
            } else if cleanedTerm.contains("C") {
                c = true
            }
            
            // Marcar las celdas correspondientes en el mapa K
            if let aVal = a {
                let row = aVal ? 1 : 0
                
                if let bVal = b, let cVal = c {
                    // Término completo (A, B, C)
                    let col: Int
                    switch (bVal, cVal) {
                    case (false, false): col = 0
                    case (false, true): col = 1
                    case (true, true): col = 2
                    case (true, false): col = 3
                    }
                    kmapValues[row][col] = true
                } else if let bVal = b {
                    // Término con A y B (sin C)
                    for c in [false, true] {
                        let col: Int
                        switch (bVal, c) {
                        case (false, false): col = 0
                        case (false, true): col = 1
                        case (true, true): col = 2
                        case (true, false): col = 3
                        }
                        kmapValues[row][col] = true
                    }
                } else if let cVal = c {
                    // Término con A y C (sin B)
                    for b in [false, true] {
                        let col: Int
                        switch (b, cVal) {
                        case (false, false): col = 0
                        case (false, true): col = 1
                        case (true, true): col = 2
                        case (true, false): col = 3
                        }
                        kmapValues[row][col] = true
                    }
                } else {
                    // Solo A
                    for col in 0..<4 {
                        kmapValues[row][col] = true
                    }
                }
            } else if let bVal = b, let cVal = c {
                // Término con B y C (sin A)
                for row in 0..<2 {
                    let col: Int
                    switch (bVal, cVal) {
                    case (false, false): col = 0
                    case (false, true): col = 1
                    case (true, true): col = 2
                    case (true, false): col = 3
                    }
                    kmapValues[row][col] = true
                }
            }
        }
        
        // Generar el circuito correspondiente
        generateCircuitFromKmap()
    }
    
    private var circuitEditor: some View {
        VStack {
            Text("Editor de Circuito")
                .font(.headline)
            
            // Controles de navegación
            HStack {
                Button(action: zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: resetView) {
                    Image(systemName: "arrow.uturn.left.circle")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Text("Usa dos dedos para mover y hacer zoom")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Canvas con scroll
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                CircuitCanvas(
                    components: $circuitComponents,
                    selectedComponent: $selectedComponent,
                    connectionStart: $connectionStart,
                    tempConnection: $tempConnection,
                    outputValue: $outputValue,
                    kmapValues: $kmapValues,
                    booleanEquation: $booleanEquation,
                    variables: $variables
                )
                .frame(width: 1500, height: 1000)
            }
            .frame(height: 400)
            
            // Paleta de componentes
            componentPalette
        }
        .padding()
    }
    
    private func zoomIn() {
        // Implementado en CircuitCanvas
    }
    
    private func zoomOut() {
        // Implementado en CircuitCanvas
    }
    
    private func resetView() {
        // Implementado en CircuitCanvas
    }
    
    private var componentPalette: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ComponentType.allCases, id: \.self) { type in
                    Button(action: { addGate(type: type) }) {
                        VStack {
                            Image(systemName: iconName(for: type))
                                .font(.system(size: 20))
                            Text(type.rawValue)
                                .font(.caption2)
                        }
                        .frame(width: 60, height: 50)
                        .background(color(for: type))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    }
                    .contextMenu {
                        Button(action: {
                            addMultipleGates(type: type, count: 5)
                        }) {
                            Label("Agregar 5", systemImage: "plus.square.on.square")
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func addGate(type: ComponentType) {
        let newName: String
        let basePosition: CGPoint
        
        switch type {
        case .input:
            newName = "\(type.rawValue.prefix(1))\(circuitComponents.filter { $0.type == .input }.count + 1)"
            basePosition = CGPoint(x: 200, y: 100)
        case .output:
            newName = "OUT"
            basePosition = CGPoint(x: 800, y: 225)
        case .andGate:
            newName = "AND\(circuitComponents.filter { $0.type == .andGate }.count + 1)"
            basePosition = CGPoint(x: 400, y: 150)
        case .orGate:
            newName = "OR\(circuitComponents.filter { $0.type == .orGate }.count + 1)"
            basePosition = CGPoint(x: 600, y: 225)
        case .notGate:
            newName = "NOT\(circuitComponents.filter { $0.type == .notGate }.count + 1)"
            basePosition = CGPoint(x: 400, y: 300)
        }
        
        let position = findOptimalPosition(near: basePosition, avoiding: circuitComponents)
        
        let newComponent = CircuitComponent(
            type: type,
            name: newName,
            position: position
        )
        circuitComponents.append(newComponent)
        selectedComponent = newComponent.id
    }
    
    private func addMultipleGates(type: ComponentType, count: Int) {
        for i in 0..<count {
            addGate(type: type)
        }
    }
    
    private func findOptimalPosition(near point: CGPoint, avoiding existingComponents: [CircuitComponent]) -> CGPoint {
        var position = point
        let gridSize: CGFloat = 60
        var attempts = 0
        var spiralRadius: CGFloat = 0
        
        while existingComponents.contains(where: { component in
            abs(component.position.x - position.x) < gridSize &&
            abs(component.position.y - position.y) < gridSize
        }) && attempts < 20 {
            attempts += 1
            spiralRadius += gridSize
            let angle = CGFloat(attempts) * 0.5
            position.x = point.x + spiralRadius * cos(angle)
            position.y = point.y + spiralRadius * sin(angle)
        }
        
        return position
    }
    
    private func iconName(for type: ComponentType) -> String {
        switch type {
        case .input: return "circle.fill"
        case .output: return "circle.fill"
        case .notGate: return "1.circle"
        default: return "square"
        }
    }
    
    private func color(for type: ComponentType) -> Color {
        switch type {
        case .input: return .blue
        case .output: return .red
        case .andGate: return .orange
        case .orGate: return .purple
        case .notGate: return .green
        }
    }
    
    private var circuitMiniView: some View {
        VStack {
            Text("Vista Previa del Circuito")
                .font(.subheadline)
            
            GeometryReader { geometry in
                ZStack {
                    // Fondo
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                    
                    // Conexiones
                    ForEach(circuitComponents) { component in
                        ForEach(component.connectedTo, id: \.self) { connectedId in
                            if let connectedComponent = circuitComponents.first(where: { $0.id == connectedId }) {
                                let from = scalePosition(connectedComponent.position, for: geometry.size)
                                let to = scalePosition(component.position, for: geometry.size)
                                ConnectionView(
                                    from: from,
                                    to: to,
                                    isActive: connectedComponent.value
                                )
                            }
                        }
                    }
                    
                    // Componentes
                    ForEach(circuitComponents) { component in
                        CircuitComponentView(
                            component: component,
                            isSelected: false,
                            onTap: {},
                            onDrag: { _ in },
                            onConnectionStart: {},
                            onDelete: {}
                        )
                        .position(scalePosition(component.position, for: geometry.size))
                        .allowsHitTesting(false)
                    }
                }
            }
            .frame(height: 150)
        }
        .padding()
        .cardStyle()
    }
    
    private func scalePosition(_ position: CGPoint, for size: CGSize) -> CGPoint {
        let scaleX = size.width / 600
        let scaleY = size.height / 300
        return CGPoint(x: position.x * scaleX, y: position.y * scaleY)
    }
    
    private var representationsSection: some View {
        VStack(spacing: 15) {
            Text("Representaciones")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            karnaughDisplay
            equationDisplay
        }
    }
    
    private var karnaughDisplay: some View {
        VStack {
            HStack {
                Text("Mapa de Karnaugh")
                    .font(.subheadline)
                Spacer()
            }
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 20)
                    
                    ForEach(["B'C'", "B'C", "BC", "BC'"], id: \.self) { header in
                        Text(header)
                            .font(.caption2)
                            .frame(width: 40, height: 20)
                    }
                }
                
                ForEach(0..<2, id: \.self) { row in
                    HStack(spacing: 0) {
                        Text(row == 0 ? "A'" : "A")
                            .font(.caption2)
                            .frame(width: 40, height: 40)
                        
                        ForEach(0..<4, id: \.self) { col in
                            Text(kmapValues[row][col] ? "1" : "0")
                                .frame(width: 40, height: 40)
                                .background(kmapValues[row][col] ? Color.green.opacity(0.2) : Color(.systemBackground))
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var equationDisplay: some View {
        VStack {
            HStack {
                Text("Ecuación Booleana")
                    .font(.subheadline)
                Spacer()
            }
            
            Text(booleanEquation)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
        }
        .cardStyle()
    }
    
    private var outputSection: some View {
        HStack {
            Text("Salida:")
                .font(.headline)
            
            Text(outputValue ? "1" : "0")
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .foregroundColor(outputValue ? .green : .red)
                .frame(width: 50, height: 50)
                .background(outputValue ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(outputValue ? Color.green : Color.red, lineWidth: 2)
                )
        }
        .padding()
        .cardStyle()
    }
    
    private var variablesPanel: some View {
        VStack {
            Text("Variables de Entrada")
                .font(.headline)
            
            HStack {
                ForEach($variables) { $variable in
                    VStack {
                        Text(variable.name)
                            .font(.headline)
                        
                        Toggle("", isOn: $variable.value)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .onChange(of: variable.value) { newValue in
                                updateCircuitInputs()
                            }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
        }
        .cardStyle()
    }
    
    private func updateCircuitInputs() {
        for variable in variables {
            if let index = circuitComponents.firstIndex(where: { $0.name == variable.name && $0.type == .input }) {
                circuitComponents[index].value = variable.value
            }
        }
        evaluateCircuit()
    }
    
    private func evaluateCircuit() {
        // Implementado en CircuitCanvas
    }
    
    private func resetAll() {
        circuitComponents.removeAll()
        kmapValues = [
            [false, false, false, false],
            [false, false, false, false]
        ]
        booleanEquation = "f = "
        outputValue = false
        variables = [
            Variable(name: "A", value: false),
            Variable(name: "B", value: false),
            Variable(name: "C", value: false)
        ]
        
        // Restaurar entradas básicas
        circuitComponents.append(CircuitComponent(
            type: .input,
            name: "A",
            position: CGPoint(x: 200, y: 100)
        ))
        circuitComponents.append(CircuitComponent(
            type: .input,
            name: "B",
            position: CGPoint(x: 200, y: 200)
        ))
        circuitComponents.append(CircuitComponent(
            type: .input,
            name: "C",
            position: CGPoint(x: 200, y: 300)
        ))
    }
}

// MARK: - Modifiers y Previews
struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
}

struct DigitalLogicView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DigitalLogicView()
                .previewDisplayName("Light Mode")
            
            DigitalLogicView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
