import SwiftUI

struct LogicaConjuntosView: View {
    @State private var conjuntos: [String] = ["1, 2, 3", "2, 3, 4", "3, 4, 5"]
    @State private var operacion: String = "Unión"
    @State private var resultado: Set<String> = []
    @State private var mostrarVisualizaciones: Bool = true
    @State private var mostrarHistorial: Bool = false
    @State private var historial: [String] = []
    @State private var seleccionHistorial: Set<String> = []
    @State private var tamanoUniverso: String = "10"
    @State private var mostrarConfigUniverso: Bool = false
    @State private var interseccionesPares: [String] = []
    
    let operaciones = [
        "Unión", "Intersección", "Diferencia", "Complemento",
        "Ley de Morgan 1", "Ley de Morgan 2", "Doble Negación",
        "Conmutativa Unión", "Conmutativa Intersección",
        "Asociativa Unión", "Asociativa Intersección",
        "Idempotencia Unión", "Idempotencia Intersección",
        "Contradicción", "Distributiva Unión", "Distributiva Intersección"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header con botones
                HStack {
                    Button(action: {
                        mostrarHistorial.toggle()
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .padding(8)
                    }
                    
                    Spacer()
                    
                    Text("Lógica y Conjuntos")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        mostrarConfigUniverso.toggle()
                    }) {
                        Image(systemName: "globe")
                            .font(.title2)
                            .padding(8)
                    }
                }
                .padding(.horizontal)
                
                // Configuración del universo
                if mostrarConfigUniverso {
                    VStack {
                        HStack {
                            Text("Tamaño del Universo:")
                            TextField("Número", text: $tamanoUniverso)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                            
                            Button("Aplicar") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                calcularOperacion()
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("Universo: \(universo().sorted().map { $0 }.joined(separator: ", "))")
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Sección de Conjuntos
                Group {
                    ForEach(0..<conjuntos.count, id: \.self) { index in
                        HStack {
                            TextField("Conjunto \(index+1) (ej. 1, 2, 3)", text: $conjuntos[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: conjuntos[index]) { _ in
                                    calcularOperacion()
                                }
                            
                            if conjuntos.count > 1 {
                                Button(action: {
                                    conjuntos.remove(at: index)
                                    calcularOperacion()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        conjuntos.append("")
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Agregar Conjunto")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // Selector de Operación
                Menu {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(operaciones, id: \.self) { op in
                                Button(action: {
                                    operacion = op
                                    calcularOperacion()
                                }) {
                                    Text(op)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                        .background(operacion == op ? Color.blue.opacity(0.2) : Color.clear)
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .frame(height: min(CGFloat(operaciones.count) * 44, 300))
                } label: {
                    HStack {
                        Text(operacion)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Botones de Acción
                HStack(spacing: 15) {
                    Button(action: calcularOperacion) {
                        Text("Calcular")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: borrarCampos) {
                        Text("Borrar")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // Resultado
                VStack(alignment: .leading, spacing: 10) {
                    Text("Resultado:")
                        .font(.headline)
                    
                    if operacion == "Intersección" && conjuntos.count > 2 {
                        ForEach(interseccionesPares, id: \.self) { texto in
                            Text(texto)
                        }
                    } else {
                        Text(formatearResultado(resultado))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Botón para invertir conjuntos
                if conjuntos.count >= 2 {
                    Button(action: invertirConjuntos) {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                            Text("Invertir Conjuntos")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // Visualizaciones
                if mostrarVisualizaciones {
                    VStack(spacing: 30) {
                        TablaPertenenciaConjuntosView(
                            conjuntos: conjuntos.map { limpiarConjunto($0) },
                            resultado: resultado,
                            operacion: operacion,
                            universo: universo()
                        )
                        .frame(height: 200)
                        
                        if conjuntos.count <= 3 {
                            DiagramaVennConjuntosView(
                                conjuntos: conjuntos.map { limpiarConjunto($0) },
                                resultado: resultado,
                                operacion: operacion
                            )
                            .frame(height: 250)
                        }
                        
                        CircuitoLogicoConjuntosView(operacion: operacion)
                            .frame(height: 200)
                        
                        EcuacionConjuntosView(operacion: operacion)
                            .frame(height: 80)
                    }
                    .padding()
                    .transition(.slide)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $mostrarHistorial) {
            NavigationView {
                List(selection: $seleccionHistorial) {
                    ForEach(historial.reversed(), id: \.self) { item in
                        Text(item)
                    }
                    .onDelete { indices in
                        let reversedIndices = indices.map { historial.count - 1 - $0 }
                        historial.remove(atOffsets: IndexSet(reversedIndices))
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Borrar") {
                            historial.removeAll()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cerrar") {
                            mostrarHistorial = false
                        }
                    }
                }
                .navigationTitle("Historial (\(historial.count))")
                .environment(\.editMode, .constant(seleccionHistorial.isEmpty ? .inactive : .active))
            }
        }
        .animation(.easeInOut, value: mostrarVisualizaciones)
        .animation(.easeInOut, value: mostrarConfigUniverso)
        .onAppear { calcularOperacion() }
    }
    
    // Funciones auxiliares
    func universo() -> Set<String> {
        guard let n = Int(tamanoUniverso), n > 0 else { return Set() }
        return Set((1...n).map { String($0) })
    }
    
    func invertirConjuntos() {
        guard conjuntos.count >= 2 else { return }
        conjuntos.swapAt(0, 1)
        calcularOperacion()
    }
    
    func borrarCampos() {
        conjuntos = ["", ""]
        resultado = []
        interseccionesPares = []
        operacion = "Unión"
    }
    
    func calcularOperacion() {
        guard !conjuntos.isEmpty else {
            resultado = []
            interseccionesPares = []
            return
        }
        
        let sets = conjuntos.map { limpiarConjunto($0) }
        let universal = universo()
        interseccionesPares = []
        
        switch operacion {
        case "Unión":
            resultado = sets.reduce(Set<String>()) { $0.union($1) }
        case "Intersección":
            if sets.count == 1 {
                resultado = sets[0]
            } else if sets.count == 2 {
                resultado = sets[0].intersection(sets[1])
            } else {
                resultado = Set<String>()
                for i in 0..<sets.count {
                    for j in (i+1)..<sets.count {
                        let interseccion = sets[i].intersection(sets[j])
                        if !interseccion.isEmpty {
                            interseccionesPares.append("C\(i+1) ∩ C\(j+1) = \(formatearResultado(interseccion))")
                            resultado = resultado.union(interseccion)
                        }
                    }
                }
            }
        case "Diferencia":
            resultado = sets.count >= 2 ? sets[0].subtracting(sets[1]) : Set<String>()
        case "Complemento":
            resultado = universal.subtracting(sets.first ?? Set<String>())
        case "Ley de Morgan 1":
            resultado = sets.count >= 2 ? universal.subtracting(sets[0].union(sets[1])) : Set<String>()
        case "Ley de Morgan 2":
            resultado = sets.count >= 2 ? universal.subtracting(sets[0].intersection(sets[1])) : Set<String>()
        case "Doble Negación":
            resultado = universal.subtracting(universal.subtracting(sets.first ?? Set<String>()))
        case "Conmutativa Unión":
            resultado = sets.count >= 2 ? sets[1].union(sets[0]) : Set<String>()
        case "Conmutativa Intersección":
            resultado = sets.count >= 2 ? sets[1].intersection(sets[0]) : Set<String>()
        case "Asociativa Unión":
            resultado = sets.count >= 3 ? sets[0].union(sets[1]).union(sets[2]) :
                         sets.count >= 2 ? sets[0].union(sets[1]) : sets.first ?? Set<String>()
        case "Asociativa Intersección":
            resultado = sets.count >= 3 ? sets[0].intersection(sets[1]).intersection(sets[2]) :
                         sets.count >= 2 ? sets[0].intersection(sets[1]) : sets.first ?? Set<String>()
        case "Idempotencia Unión":
            resultado = sets.first?.union(sets.first ?? Set<String>()) ?? Set<String>()
        case "Idempotencia Intersección":
            resultado = sets.first?.intersection(sets.first ?? Set<String>()) ?? Set<String>()
        case "Contradicción":
            resultado = sets.first?.intersection(universal.subtracting(sets.first ?? Set<String>())) ?? Set<String>()
        case "Distributiva Unión":
            resultado = sets.count >= 3 ? sets[0].union(sets[1].intersection(sets[2])) : Set<String>()
        case "Distributiva Intersección":
            resultado = sets.count >= 3 ? sets[0].intersection(sets[1].union(sets[2])) : Set<String>()
        default:
            resultado = []
        }
        
        // Agregar al historial
        let conjuntosStr = conjuntos.enumerated().map { "\($0+1)=\($1)" }.joined(separator: ", ")
        let entrada = "\(operacion): \(conjuntosStr) → \(formatearResultado(resultado))"
        if !historial.contains(entrada) {
            historial.append(entrada)
        }
    }
    
    func limpiarConjunto(_ texto: String) -> Set<String> {
        Set(texto.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty })
    }
    
    func formatearResultado(_ conjunto: Set<String>) -> String {
        conjunto.isEmpty ? "∅" : "{\(conjunto.sorted().joined(separator: ", "))}"
    }
}

// Vistas auxiliares (exactamente igual que antes)
struct TablaPertenenciaConjuntosView: View {
    let conjuntos: [Set<String>]
    let resultado: Set<String>
    let operacion: String
    let universo: Set<String>
    
    var elementos: [String] {
        if operacion == "Complemento" {
            return Array(universo).sorted()
        }
        return Array(conjuntos.reduce(Set<String>(), { $0.union($1) })).sorted()
    }
    
    var body: some View {
        VStack {
            Text("Tabla de Pertenencia")
                .font(.headline)
                .padding(.bottom, 5)
            
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Elemento").bold()
                        ForEach(elementos, id: \.self) { elemento in
                            Text(elemento)
                        }
                    }
                    .frame(width: 70)
                    
                    ForEach(0..<conjuntos.count, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("∈ \(index+1)").bold()
                            ForEach(elementos, id: \.self) { elemento in
                                Text(conjuntos[index].contains(elemento) ? "✓" : "✗")
                            }
                        }
                        .frame(width: 50)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Resultado").bold()
                        ForEach(elementos, id: \.self) { elemento in
                            Text(resultado.contains(elemento) ? "✓" : "✗")
                        }
                    }
                    .frame(width: 70)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct DiagramaVennConjuntosView: View {
    let conjuntos: [Set<String>]
    let resultado: Set<String>
    let operacion: String
    
    var body: some View {
        VStack {
            Text("Diagrama de Venn")
                .font(.headline)
                .padding(.bottom, 5)
            
            ZStack {
                if conjuntos.count >= 1 {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 120)
                        .offset(x: conjuntos.count == 1 ? 0 : -30)
                }
                
                if conjuntos.count >= 2 {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 120)
                        .offset(x: conjuntos.count == 2 ? 0 : 30,
                                y: conjuntos.count == 2 ? 0 : -20)
                }
                
                if conjuntos.count >= 3 {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 120)
                        .offset(x: 0, y: 30)
                }
                
                ForEach(Array(resultado), id: \.self) { elemento in
                    Text(elemento)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(5)
                        .background(Circle().fill(Color.white))
                        .offset(posicionElemento(elemento))
                }
            }
            .frame(height: 200)
        }
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func posicionElemento(_ elemento: String) -> CGSize {
        guard conjuntos.count >= 2 else { return .zero }
        
        let enA = conjuntos[0].contains(elemento)
        let enB = conjuntos.count > 1 ? conjuntos[1].contains(elemento) : false
        let enC = conjuntos.count > 2 ? conjuntos[2].contains(elemento) : false
        
        switch (enA, enB, enC) {
        case (true, false, false): return CGSize(width: -50, height: -30)
        case (false, true, false): return CGSize(width: 50, height: -30)
        case (false, false, true): return CGSize(width: 0, height: 40)
        case (true, true, false): return CGSize(width: 0, height: -30)
        case (true, false, true): return CGSize(width: -25, height: 10)
        case (false, true, true): return CGSize(width: 25, height: 10)
        case (true, true, true): return CGSize(width: 0, height: 0)
        default: return CGSize(width: CGFloat.random(in: -80...80),
                              height: CGFloat.random(in: -60...60))
        }
    }
}

struct CircuitoLogicoConjuntosView: View {
    let operacion: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Circuito Lógico")
                .font(.headline)
                .padding(.bottom, 10)
            
            ZStack {
                Path { path in
                    if ["Unión", "Intersección", "Diferencia"].contains(operacion) {
                        path.move(to: CGPoint(x: 50, y: 30))
                        path.addLine(to: CGPoint(x: 100, y: 30))
                        
                        path.move(to: CGPoint(x: 50, y: 70))
                        path.addLine(to: CGPoint(x: 100, y: 70))
                    }
                    
                    path.move(to: CGPoint(x: 200, y: 50))
                    path.addLine(to: CGPoint(x: 250, y: 50))
                }
                .stroke(Color.gray, lineWidth: 2)
                
                entrada("A", posicion: CGPoint(x: 50, y: 30))
                entrada("B", posicion: CGPoint(x: 50, y: 70))
                
                switch operacion {
                case "Unión":
                    compuertaOR(posicion: CGPoint(x: 150, y: 50))
                case "Intersección":
                    compuertaAND(posicion: CGPoint(x: 150, y: 50))
                case "Complemento":
                    compuertaNOT(posicion: CGPoint(x: 150, y: 50))
                default:
                    compuertaGeneric(posicion: CGPoint(x: 150, y: 50))
                }
                
                Text("Resultado")
                    .position(x: 300, y: 50)
            }
            .frame(height: 120)
        }
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func entrada(_ letra: String, posicion: CGPoint) -> some View {
        Text(letra)
            .font(.system(size: 16, weight: .bold))
            .padding(8)
            .background(Circle().fill(Color.white))
            .position(posicion)
    }
    
    private func compuertaAND(posicion: CGPoint) -> some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 30, y: 0))
                path.addQuadCurve(to: CGPoint(x: 30, y: 40),
                                 control: CGPoint(x: 45, y: 20))
                path.addLine(to: CGPoint(x: 0, y: 40))
                path.closeSubpath()
            }
            .fill(Color.blue)
            .frame(width: 40, height: 40)
            
            Text("AND")
                .font(.caption)
                .foregroundColor(.white)
        }
        .position(posicion)
    }
    
    private func compuertaOR(posicion: CGPoint) -> some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 20))
                path.addQuadCurve(to: CGPoint(x: 40, y: 20),
                                 control: CGPoint(x: 20, y: -10))
                path.addQuadCurve(to: CGPoint(x: 0, y: 20),
                                 control: CGPoint(x: 20, y: 50))
            }
            .fill(Color.green)
            .frame(width: 50, height: 40)
            
            Text("OR")
                .font(.caption)
                .foregroundColor(.white)
        }
        .position(posicion)
    }
    
    private func compuertaNOT(posicion: CGPoint) -> some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 20))
                path.addLine(to: CGPoint(x: 20, y: 20))
                path.addLine(to: CGPoint(x: 40, y: 0))
                path.addLine(to: CGPoint(x: 40, y: 40))
                path.addLine(to: CGPoint(x: 20, y: 20))
            }
            .fill(Color.red)
            .frame(width: 50, height: 40)
            
            Text("NOT")
                .font(.caption)
                .foregroundColor(.white)
                .offset(x: 10)
        }
        .position(posicion)
    }
    
    private func compuertaGeneric(posicion: CGPoint) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.purple)
                .frame(width: 40, height: 40)
                .cornerRadius(5)
            
            Text("OP")
                .font(.caption)
                .foregroundColor(.white)
        }
        .position(posicion)
    }
}

struct EcuacionConjuntosView: View {
    let operacion: String
    
    var body: some View {
        VStack {
            Text("Ecuación Formal")
                .font(.headline)
                .padding(.bottom, 5)
            
            Text(ecuacionTexto())
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
    
    func ecuacionTexto() -> String {
        switch operacion {
        case "Ley de Morgan 1": return "¬(A ∪ B) = ¬A ∩ ¬B"
        case "Ley de Morgan 2": return "¬(A ∩ B) = ¬A ∪ ¬B"
        case "Doble Negación": return "¬¬A = A"
        case "Conmutativa Unión": return "A ∪ B = B ∪ A"
        case "Conmutativa Intersección": return "A ∩ B = B ∩ A"
        case "Asociativa Unión": return "(A ∪ B) ∪ C = A ∪ (B ∪ C)"
        case "Asociativa Intersección": return "(A ∩ B) ∩ C = A ∩ (B ∩ C)"
        case "Idempotencia Unión": return "A ∪ A = A"
        case "Idempotencia Intersección": return "A ∩ A = A"
        case "Contradicción": return "A ∩ ¬A = ∅"
        case "Distributiva Unión": return "A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C)"
        case "Distributiva Intersección": return "A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C)"
        default:
            switch operacion {
            case "Unión": return "A ∪ B = {x | x ∈ A ∨ x ∈ B}"
            case "Intersección": return "A ∩ B = {x | x ∈ A ∧ x ∈ B}"
            case "Diferencia": return "A ∖ B = {x | x ∈ A ∧ x ∉ B}"
            case "Complemento": return "A' = {x | x ∉ A ∧ x ∈ U}"
            default: return operacion
            }
        }
    }
}

#Preview {
    LogicaConjuntosView()
}
