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
    let component: CircuitComponent
    let isSelected: Bool
    let onTap: () -> Void
    let onDrag: (DragGesture.Value) -> Void
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
                .onChanged(onDrag)
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
            
            Text(component.name)
                .foregroundColor(.white)
                .font(.caption)
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
            
            Text("OUT")
                .foregroundColor(.white)
                .font(.caption)
        }
        .overlay(
            Circle()
                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
        )
    }
    
    private var andGateView: some View {
        Text("AND")
            .frame(width: 50, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(component.value ? Color.green.opacity(0.3) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.yellow : Color.orange, lineWidth: 2)
                    )
            )
    }
    
    private var orGateView: some View {
        Text("OR")
            .frame(width: 50, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(component.value ? Color.green.opacity(0.3) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.yellow : Color.purple, lineWidth: 2)
                    )
            )
    }
    
    private var notGateView: some View {
        ZStack {
            Circle()
                .fill(component.value ? Color.green.opacity(0.3) : Color.white)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.yellow : Color.green, lineWidth: 2)
                )
            
            Text("1")
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

struct CircuitCanvas: View {
    @Binding var components: [CircuitComponent]
    @Binding var selectedComponent: UUID?
    @Binding var connectionStart: UUID?
    @Binding var tempConnection: CGPoint?
    @Binding var outputValue: Bool
    @Binding var kmapValues: [[Bool]]
    @Binding var booleanEquation: String
    @Binding var variables: [Variable]
    
    var body: some View {
        ZStack {
            // Fondo del lienzo
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 3)
            
            // Dibuja todas las conexiones
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
            
            // Conexión temporal
            if let startId = connectionStart,
               let startComponent = components.first(where: { $0.id == startId }),
               let endPoint = tempConnection {
                ConnectionView(
                    from: startComponent.position,
                    to: endPoint,
                    isActive: false
                )
            }
            
            // Dibuja componentes
            ForEach(components) { component in
                CircuitComponentView(
                    component: component,
                    isSelected: selectedComponent == component.id,
                    onTap: {
                        handleTap(component: component)
                    },
                    onDrag: { gesture in
                        handleDrag(component: component, gesture: gesture)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if let startId = connectionStart {
                        tempConnection = value.location
                    }
                }
                .onEnded { _ in
                    tempConnection = nil
                    connectionStart = nil
                }
        )
    }
    
    private func handleTap(component: CircuitComponent) {
        if connectionStart == nil {
            selectedComponent = component.id
            if component.type == .input, let index = components.firstIndex(where: { $0.id == component.id }) {
                components[index].value.toggle()
                evaluateCircuit()
            }
        } else if connectionStart != component.id {
            connectComponents(from: connectionStart!, to: component.id)
            connectionStart = nil
        }
    }
    
    private func handleDrag(component: CircuitComponent, gesture: DragGesture.Value) {
        if selectedComponent == component.id {
            let newPosition = gesture.location
            if let index = components.firstIndex(where: { $0.id == component.id }) {
                components[index].position = newPosition
            }
        }
    }
    
    private func deleteComponent(_ id: UUID) {
        components.removeAll { $0.id == id }
        for i in components.indices {
            components[i].connectedTo.removeAll { $0 == id }
        }
        evaluateCircuit()
    }
    
    private func connectComponents(from startId: UUID, to endId: UUID) {
        guard let startComponent = components.first(where: { $0.id == startId }),
              let endIndex = components.firstIndex(where: { $0.id == endId }) else { return }
        
        if isValidConnection(from: startComponent, to: components[endIndex]) {
            components[endIndex].connectedTo.append(startId)
            evaluateCircuit()
        }
    }
    
    private func isValidConnection(from: CircuitComponent, to: CircuitComponent) -> Bool {
        if to.type == .input { return false }
        if createsCycle(start: from.id, end: to.id) { return false }
        
        switch to.type {
        case .andGate, .orGate: return to.connectedTo.count < 2
        case .notGate: return to.connectedTo.isEmpty
        default: return true
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
    
    private func evaluateCircuit() {
        resetComponentValues()
        let evaluationOrder = getEvaluationOrder()
        
        for componentId in evaluationOrder {
            guard let index = components.firstIndex(where: { $0.id == componentId }) else { continue }
            
            switch components[index].type {
            case .input: continue
                
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
                outputValue = components[index].value
                
            case .output:
                if let inputId = components[index].connectedTo.first,
                   let input = components.first(where: { $0.id == inputId }) {
                    components[index].value = input.value
                }
            }
        }
        
        updateKmapFromCircuit()
        updateEquationFromCircuit()
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
        
        for component in components {
            if component.type == .orGate || component.type == .output {
                visit(component.id)
            }
        }
        
        return order
    }
    
    private func updateKmapFromCircuit() {
        guard let inputA = components.first(where: { $0.name == "A" }),
              let inputB = components.first(where: { $0.name == "B" }),
              let inputC = components.first(where: { $0.name == "C" }) else { return }
        
        let originalValues = (a: inputA.value, b: inputB.value, c: inputC.value)
        
        for a in [false, true] {
            for b in [false, true] {
                for c in [false, true] {
                    if let indexA = components.firstIndex(where: { $0.name == "A" }) {
                        components[indexA].value = a
                    }
                    if let indexB = components.firstIndex(where: { $0.name == "B" }) {
                        components[indexB].value = b
                    }
                    if let indexC = components.firstIndex(where: { $0.name == "C" }) {
                        components[indexC].value = c
                    }
                    
                    evaluateCircuit()
                    
                    let row = a ? 1 : 0
                    let col: Int
                    switch (b, c) {
                    case (false, false): col = 0
                    case (false, true): col = 1
                    case (true, true): col = 2
                    case (true, false): col = 3
                    }
                    
                    kmapValues[row][col] = outputValue
                }
            }
        }
        
        // Restaurar valores
        if let indexA = components.firstIndex(where: { $0.name == "A" }) {
            components[indexA].value = originalValues.a
        }
        if let indexB = components.firstIndex(where: { $0.name == "B" }) {
            components[indexB].value = originalValues.b
        }
        if let indexC = components.firstIndex(where: { $0.name == "C" }) {
            components[indexC].value = originalValues.c
        }
        
        evaluateCircuit()
    }
    
    private func updateEquationFromCircuit() {
        guard let output = components.first(where: { $0.type == .orGate || $0.type == .output }) else {
            booleanEquation = "f = 0"
            return
        }
        
        var terms: [String] = []
        
        for inputId in output.connectedTo {
            if let gate = components.first(where: { $0.id == inputId }) {
                switch gate.type {
                case .andGate:
                    var andTerms: [String] = []
                    for andInputId in gate.connectedTo {
                        if let input = components.first(where: { $0.id == andInputId }) {
                            andTerms.append(input.value ? input.name : "\(input.name)'")
                        }
                    }
                    terms.append(andTerms.joined())
                    
                case .notGate:
                    if let notInputId = gate.connectedTo.first,
                       let input = components.first(where: { $0.id == notInputId }) {
                        terms.append("\(input.name)'")
                    }
                    
                case .input:
                    terms.append(gate.value ? gate.name : "\(gate.name)'")
                    
                default:
                    break
                }
            }
        }
        
        booleanEquation = terms.isEmpty ? "f = 0" : "f = " + terms.joined(separator: " + ")
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
                    representationsSection
                    outputSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: setupInitialCircuit)
    }
    
    // MARK: - Componentes UI
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lógica Digital")
                .font(.largeTitle).bold()
                .foregroundColor(.blue)
            
            Text("Diseña circuitos lógicos y visualiza sus representaciones")
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
                            .frame(width: 60, height: 30)
                    }
                }
                
                ForEach(0..<2, id: \.self) { row in
                    HStack(spacing: 0) {
                        Text(row == 0 ? "A'" : "A")
                            .frame(width: 60, height: 60)
                        
                        ForEach(0..<4, id: \.self) { col in
                            Button(action: {
                                kmapValues[row][col].toggle()
                                updateFromKmap()
                            }) {
                                Text(kmapValues[row][col] ? "1" : "0")
                                    .frame(width: 60, height: 60)
                                    .background(kmapValues[row][col] ? Color.green.opacity(0.2) : Color.white)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private var equationEditor: some View {
        VStack {
            Text("Editor de Ecuación")
                .font(.headline)
            
            TextEditor(text: $booleanEquation)
                .frame(height: 100)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
        }
        .padding()
    }
    
    private var circuitEditor: some View {
        VStack {
            Text("Editor de Circuito")
                .font(.headline)
            
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
            .frame(height: 400)
            
            HStack(spacing: 15) {
                ForEach(ComponentType.allCases, id: \.self) { type in
                    Button(action: { addGate(type: type) }) {
                        VStack {
                            Image(systemName: iconName(for: type))
                            Text(type.rawValue)
                                .font(.caption)
                        }
                        .frame(width: 60, height: 50)
                        .background(color(for: type))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
    }
    
    private func iconName(for type: ComponentType) -> String {
        switch type {
        case .input: return "circle.fill"
        case .output: return "circle.fill"
        case .notGate: return "1.circle"
        default: return ""
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
    
    private var representationsSection: some View {
        VStack(spacing: 15) {
            Text("Representaciones")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            karnaughDisplay
            equationDisplay
            circuitDisplay
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
                            .font(.caption)
                            .frame(width: 40, height: 20)
                    }
                }
                
                ForEach(0..<2, id: \.self) { row in
                    HStack(spacing: 0) {
                        Text(row == 0 ? "A'" : "A")
                            .font(.caption)
                            .frame(width: 40, height: 40)
                        
                        ForEach(0..<4, id: \.self) { col in
                            Text(kmapValues[row][col] ? "1" : "0")
                                .frame(width: 40, height: 40)
                                .background(kmapValues[row][col] ? Color.green.opacity(0.2) : Color.white)
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
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .cardStyle()
    }
    
    private var circuitDisplay: some View {
        VStack {
            HStack {
                Text("Circuito Lógico")
                    .font(.subheadline)
                Spacer()
            }
            
            ZStack {
                // Conexiones
                ForEach(circuitComponents) { component in
                    ForEach(component.connectedTo, id: \.self) { inputId in
                        if let input = circuitComponents.first(where: { $0.id == inputId }) {
                            ConnectionView(
                                from: input.position,
                                to: component.position,
                                isActive: input.value
                            )
                        }
                    }
                }
                
                // Componentes
                ForEach(circuitComponents) { component in
                    CircuitComponentView(
                        component: component,
                        isSelected: selectedComponent == component.id,
                        onTap: {
                            if connectionStart == nil {
                                selectedComponent = component.id
                            } else if connectionStart != component.id {
                                connectComponents(from: connectionStart!, to: component.id)
                                connectionStart = nil
                            }
                        },
                        onDrag: { _ in },
                        onConnectionStart: {
                            connectionStart = component.id
                        },
                        onDelete: {
                            deleteComponent(component.id)
                        }
                    )
                    .position(component.position)
                }
            }
            .frame(height: 200)
        }
        .cardStyle()
    }
    
    private var outputSection: some View {
        HStack {
            Text("Salida:")
                .font(.title2)
            
            Text(outputValue ? "1" : "0")
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundColor(outputValue ? .green : .red)
                .frame(width: 60, height: 60)
                .background(outputValue ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(outputValue ? Color.green : Color.red, lineWidth: 2)
                )
        }
        .padding()
        .cardStyle()
    }
    
    // MARK: - Lógica
    
    private func setupInitialCircuit() {
        // Crear componentes como variables mutables
        var inputA = CircuitComponent(type: .input, name: "A", position: CGPoint(x: 100, y: 80))
        var inputB = CircuitComponent(type: .input, name: "B", position: CGPoint(x: 100, y: 160))
        var inputC = CircuitComponent(type: .input, name: "C", position: CGPoint(x: 100, y: 240))
        
        var notGate = CircuitComponent(type: .notGate, name: "NOT1", position: CGPoint(x: 250, y: 240))
        var andGate = CircuitComponent(type: .andGate, name: "AND1", position: CGPoint(x: 250, y: 120))
        var orGate = CircuitComponent(type: .orGate, name: "OR1", position: CGPoint(x: 400, y: 180))
        var output = CircuitComponent(type: .output, name: "OUT", position: CGPoint(x: 550, y: 180))
        
        // Configurar conexiones
        andGate.connectedTo = [inputA.id, inputB.id]
        notGate.connectedTo = [inputC.id]
        orGate.connectedTo = [andGate.id, notGate.id]
        output.connectedTo = [orGate.id]
        
        // Asignar al array
        circuitComponents = [inputA, inputB, inputC, notGate, andGate, orGate, output]
        
        // Evaluar circuito inicial
        evaluateCircuit()
    }
    
    private func addGate(type: ComponentType) {
        let newName: String
        let position: CGPoint
        
        switch type {
        case .input:
            newName = "\(type.rawValue.prefix(1))\(circuitComponents.filter { $0.type == .input }.count + 1)"
            position = CGPoint(x: 100, y: 80 + CGFloat(circuitComponents.filter { $0.type == .input }.count * 80))
        case .output:
            newName = "OUT"
            position = CGPoint(x: 550, y: 180)
        case .andGate:
            newName = "AND\(circuitComponents.filter { $0.type == .andGate }.count + 1)"
            position = CGPoint(x: 250, y: 120 + CGFloat(circuitComponents.filter { $0.type == .andGate }.count * 60))
        case .orGate:
            newName = "OR\(circuitComponents.filter { $0.type == .orGate }.count + 1)"
            position = CGPoint(x: 250, y: 180 + CGFloat(circuitComponents.filter { $0.type == .orGate }.count * 60))
        case .notGate:
            newName = "NOT\(circuitComponents.filter { $0.type == .notGate }.count + 1)"
            position = CGPoint(x: 250, y: 240 + CGFloat(circuitComponents.filter { $0.type == .notGate }.count * 60))
        }
        
        let newComponent = CircuitComponent(
            type: type,
            name: newName,
            position: position
        )
        circuitComponents.append(newComponent)
        selectedComponent = newComponent.id
    }
    
    private func updateFromKmap() {
        var terms: [String] = []
        
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
                    terms.append("\(a)\(bc)")
                }
            }
        }
        
        booleanEquation = terms.isEmpty ? "f = 0" : "f = " + terms.joined(separator: " + ")
    }
    
    private func evaluateCircuit() {
        // La evaluación real ocurre en CircuitCanvas
    }
    
    private func connectComponents(from startId: UUID, to endId: UUID) {
        guard let startComponent = circuitComponents.first(where: { $0.id == startId }),
              let endIndex = circuitComponents.firstIndex(where: { $0.id == endId }) else { return }
        
        if !circuitComponents[endIndex].connectedTo.contains(startId) {
            circuitComponents[endIndex].connectedTo.append(startId)
        }
    }
    
    private func deleteComponent(_ id: UUID) {
        circuitComponents.removeAll { $0.id == id }
        for i in circuitComponents.indices {
            circuitComponents[i].connectedTo.removeAll { $0 == id }
        }
    }
}

// MARK: - Modifiers y Previews

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
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
        DigitalLogicView()
    }
}
