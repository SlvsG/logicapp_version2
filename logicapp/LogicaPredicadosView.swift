import SwiftUI

struct LogicaProposicionalView: View {
    @State private var proposicion: String = "P ∧ Q"
    @State private var operacion: String = "Evaluación"
    @State private var resultado: String = "Ingrese una proposición"
    @State private var mostrarVisualizaciones: Bool = true
    @State private var mostrarHistorial: Bool = false
    @State private var mostrarSimbolos: Bool = false
    @State private var historial: [String] = []
    
    let operaciones = [
        "Evaluación",
        "Negación",
        "Conjunción",
        "Disyunción",
        "Implicación",
        "Equivalencia",
        "Leyes de De Morgan",
        "Tautología",
        "Contradicción"
    ]
    
    let simbolos = ["∧", "∨", "→", "↔", "¬", "(", ")", "P", "Q", "R"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { mostrarHistorial.toggle() }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                                .padding(8)
                        }
                        
                        Spacer()
                        
                        Text("Lógica Proposicional")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: { mostrarSimbolos.toggle() }) {
                            Image(systemName: "function")
                                .font(.title2)
                                .padding(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Input field
                    TextField("Proposición (ej. P ∧ Q)", text: $proposicion)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: proposicion) { _ in
                            evaluarProposicion()
                        }
                    
                    // Symbol keyboard
                    if mostrarSimbolos {
                        VStack {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                                ForEach(simbolos, id: \.self) { simbolo in
                                    Button(action: {
                                        proposicion += simbolo
                                        evaluarProposicion()
                                    }) {
                                        Text(simbolo)
                                            .font(.title)
                                            .frame(width: 40, height: 40)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding()
                        }
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Operation picker
                    Picker("Operación", selection: $operacion) {
                        ForEach(operaciones, id: \.self) { op in
                            Text(op).tag(op)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: operacion) { _ in
                        evaluarProposicion()
                    }
                    
                    // Action buttons
                    HStack(spacing: 15) {
                        Button(action: evaluarProposicion) {
                            Text("Evaluar")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: borrarCampos) {
                            Text("Limpiar")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Result display
                    VStack {
                        Text("Resultado:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(resultado)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Interactive visualizations
                    if mostrarVisualizaciones {
                        VStack(spacing: 30) {
                            TablaVerdadView(
                                proposicion: proposicion,
                                operacion: operacion
                            )
                            .frame(minHeight: 100, maxHeight: 300)
                            .animation(.easeInOut, value: proposicion)
                            
                            EcuacionView(
                                proposicion: proposicion,
                                operacion: operacion
                            )
                            .frame(height: 80)
                            .animation(.easeInOut, value: proposicion)
                            
                            DiagramaLogicoView(
                                proposicion: proposicion,
                                operacion: operacion
                            )
                            .frame(height: 250)
                            .animation(.easeInOut, value: proposicion)
                        }
                        .padding()
                        .transition(.slide)
                    }
                }
                .padding(.vertical)
            }
            .sheet(isPresented: $mostrarHistorial) {
                HistorialView(historial: $historial, mostrarHistorial: $mostrarHistorial)
            }
            .navigationTitle("Lógica Proposicional")
            .animation(.easeInOut, value: mostrarVisualizaciones)
            .animation(.easeInOut, value: mostrarSimbolos)
        }
        .onAppear {
            evaluarProposicion()
        }
    }
    
    private func evaluarProposicion() {
        guard !proposicion.isEmpty else {
            resultado = "Ingrese una proposición"
            return
        }
        
        switch operacion {
        case "Evaluación":
            resultado = "Proposición: \(proposicion)"
        case "Negación":
            resultado = "¬(\(proposicion))"
        case "Conjunción":
            resultado = "\(proposicion) ∧ \(proposicion)"
        case "Disyunción":
            resultado = "\(proposicion) ∨ \(proposicion)"
        case "Implicación":
            resultado = "\(proposicion) → \(proposicion)"
        case "Equivalencia":
            resultado = "\(proposicion) ↔ \(proposicion)"
        case "Leyes de De Morgan":
            resultado = "¬(\(proposicion) ∧ \(proposicion)) ↔ (¬\(proposicion) ∨ ¬\(proposicion))"
        case "Tautología":
            resultado = "\(proposicion) ∨ ¬\(proposicion) ≡ ⊤"
        case "Contradicción":
            resultado = "\(proposicion) ∧ ¬\(proposicion) ≡ ⊥"
        default:
            resultado = "Operación \(operacion) aplicada"
        }
        
        let entrada = "\(operacion): \(proposicion) → \(resultado)"
        if !historial.contains(entrada) && !proposicion.isEmpty {
            historial.append(entrada)
        }
    }
    
    private func borrarCampos() {
        withAnimation {
            proposicion = ""
            resultado = "Ingrese una proposición"
        }
    }
}

struct TablaVerdadView: View {
    let proposicion: String
    let operacion: String
    
    private var variables: [String] {
        let pattern = "[A-Z]"
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: proposicion, range: NSRange(proposicion.startIndex..., in: proposicion))
        
        var vars = Set<String>()
        for match in matches {
            let range = match.range
            if let substringRange = Range(range, in: proposicion) {
                let variable = String(proposicion[substringRange])
                vars.insert(variable)
            }
        }
        return Array(vars).sorted()
    }
    
    private var combinaciones: [[String: Bool]] {
        let count = variables.count
        var combinaciones: [[String: Bool]] = []
        
        for i in 0..<(1 << count) {
            var combinacion: [String: Bool] = [:]
            for j in 0..<count {
                let variable = variables[j]
                combinacion[variable] = (i & (1 << j)) != 0
            }
            combinaciones.append(combinacion)
        }
        
        return combinaciones
    }
    
    var body: some View {
        VStack {
            Text("Tabla de Verdad")
                .font(.headline)
                .padding(.bottom, 5)
            
            if variables.isEmpty {
                Text("Ingrese una proposición con variables (P, Q, R...)")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView([.horizontal, .vertical]) {
                    HStack(spacing: 1) {
                        ForEach(variables, id: \.self) { variable in
                            Text(variable)
                                .frame(minWidth: 40, maxWidth: 60)
                                .padding(8)
                                .background(Color.blue.opacity(0.5))
                                .foregroundColor(.white)
                        }
                        
                        Text(proposicion)
                            .frame(minWidth: 100, maxWidth: 200)
                            .padding(8)
                            .background(Color.blue.opacity(0.5))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Text("Resultado")
                            .frame(minWidth: 60, maxWidth: 100)
                            .padding(8)
                            .background(Color.green.opacity(0.5))
                            .foregroundColor(.white)
                    }
                    
                    ForEach(0..<combinaciones.count, id: \.self) { index in
                        HStack(spacing: 1) {
                            ForEach(variables, id: \.self) { variable in
                                Text(combinaciones[index][variable, default: false] ? "V" : "F")
                                    .frame(minWidth: 40, maxWidth: 60)
                                    .padding(8)
                                    .background(index % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.2))
                            }
                            
                            Text(evaluar(proposicion, con: combinaciones[index]) ? "V" : "F")
                                .frame(minWidth: 100, maxWidth: 200)
                                .padding(8)
                                .background(index % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.2))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            
                            Text(evaluarOperacion(con: combinaciones[index]) ? "V" : "F")
                                .frame(minWidth: 60, maxWidth: 100)
                                .padding(8)
                                .background(index % 2 == 0 ? Color.green.opacity(0.1) : Color.green.opacity(0.2))
                        }
                    }
                }
                .frame(maxHeight: 250)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func evaluar(_ expresion: String, con valores: [String: Bool]) -> Bool {
        let expresion = expresion.replacingOccurrences(of: " ", with: "")
        
        if expresion.hasPrefix("¬") {
            let subExpresion = String(expresion.dropFirst())
            return !evaluar(subExpresion, con: valores)
        }
        
        if expresion.hasPrefix("(") && expresion.hasSuffix(")") {
            let subExpresion = String(expresion.dropFirst().dropLast())
            return evaluar(subExpresion, con: valores)
        }
        
        let operadores = ["∧", "∨", "→", "↔"]
        for operador in operadores {
            if let indice = encontrarOperadorBinario(expresion, operador: operador) {
                let izquierda = String(expresion[..<indice])
                let derecha = String(expresion[expresion.index(indice, offsetBy: 1)...])
                
                let valorIzq = evaluar(izquierda, con: valores)
                let valorDer = evaluar(derecha, con: valores)
                
                switch operador {
                case "∧": return valorIzq && valorDer
                case "∨": return valorIzq || valorDer
                case "→": return !valorIzq || valorDer
                case "↔": return valorIzq == valorDer
                default: return false
                }
            }
        }
        
        return valores[expresion] ?? false
    }
    
    private func encontrarOperadorBinario(_ expresion: String, operador: String) -> String.Index? {
        var nivelParentesis = 0
        for (i, caracter) in expresion.enumerated() {
            let index = expresion.index(expresion.startIndex, offsetBy: i)
            if caracter == "(" {
                nivelParentesis += 1
            } else if caracter == ")" {
                nivelParentesis -= 1
            } else if nivelParentesis == 0 && String(caracter) == operador {
                return index
            }
        }
        return nil
    }
    
    private func evaluarOperacion(con valores: [String: Bool]) -> Bool {
        switch operacion {
        case "Negación":
            return !evaluar(proposicion, con: valores)
        case "Leyes de De Morgan":
            if proposicion.contains("∧") {
                let partes = proposicion.components(separatedBy: " ∧ ")
                return !evaluar(partes[0], con: valores) || !evaluar(partes[1], con: valores)
            } else if proposicion.contains("∨") {
                let partes = proposicion.components(separatedBy: " ∨ ")
                return !evaluar(partes[0], con: valores) && !evaluar(partes[1], con: valores)
            }
            return false
        case "Contradicción":
            return evaluar(proposicion, con: valores) && !evaluar(proposicion, con: valores)
        case "Tautología":
            return evaluar(proposicion, con: valores) || !evaluar(proposicion, con: valores)
        default:
            return evaluar(proposicion, con: valores)
        }
    }
}

struct EcuacionView: View {
    let proposicion: String
    let operacion: String
    
    var body: some View {
        VStack {
            Text("Ecuación Formal")
                .font(.headline)
            
            Text(ecuacionFormateada())
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
    
    private func ecuacionFormateada() -> String {
        switch operacion {
        case "Negación":
            return "¬(\(proposicion))"
        case "Conjunción":
            return "\(proposicion) ∧ \(proposicion)"
        case "Disyunción":
            return "\(proposicion) ∨ \(proposicion)"
        case "Implicación":
            return "\(proposicion) → \(proposicion)"
        case "Equivalencia":
            return "\(proposicion) ↔ \(proposicion)"
        case "Leyes de De Morgan":
            return "¬(\(proposicion) ∧ \(proposicion)) ↔ (¬\(proposicion) ∨ ¬\(proposicion))"
        case "Tautología":
            return "\(proposicion) ∨ ¬\(proposicion) ≡ ⊤"
        case "Contradicción":
            return "\(proposicion) ∧ ¬\(proposicion) ≡ ⊥"
        default:
            return proposicion
        }
    }
}

struct DiagramaLogicoView: View {
    let proposicion: String
    let operacion: String
    
    var body: some View {
        VStack {
            Text("Diagrama Lógico")
                .font(.headline)
            
            ZStack {
                if operacion == "Negación" {
                    NegacionDiagram(proposicion: proposicion)
                } else {
                    if proposicion.contains("∧") {
                        if let partes = separarProposicion(proposicion, operador: "∧") {
                            ConjuncionDiagram(partes: partes)
                        } else {
                            DefaultDiagram(proposicion: proposicion)
                        }
                    } else if proposicion.contains("∨") {
                        if let partes = separarProposicion(proposicion, operador: "∨") {
                            DisyuncionDiagram(partes: partes)
                        } else {
                            DefaultDiagram(proposicion: proposicion)
                        }
                    } else if proposicion.contains("→") {
                        if let partes = separarProposicion(proposicion, operador: "→") {
                            ImplicacionDiagram(partes: partes)
                        } else {
                            DefaultDiagram(proposicion: proposicion)
                        }
                    } else if proposicion.contains("↔") {
                        if let partes = separarProposicion(proposicion, operador: "↔") {
                            EquivalenciaDiagram(partes: partes)
                        } else {
                            DefaultDiagram(proposicion: proposicion)
                        }
                    } else if proposicion.contains("¬") {
                        NegacionDiagram(proposicion: proposicion)
                    } else {
                        DefaultDiagram(proposicion: proposicion)
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func separarProposicion(_ proposicion: String, operador: String) -> (String, String)? {
        let partes = proposicion.components(separatedBy: " \(operador) ")
        guard partes.count == 2 else { return nil }
        return (partes[0], partes[1])
    }
}

struct NegacionDiagram: View {
    let proposicion: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(proposicion.replacingOccurrences(of: "¬", with: ""))
                .padding()
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 100, height: 100)
                )
            
            Text("¬")
                .font(.system(size: 30))
                .padding(5)
                .background(
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 40, height: 40)
                )
        }
    }
}

struct ConjuncionDiagram: View {
    let partes: (String, String)
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 30) {
                Text(partes.0)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 80, height: 80)
                    )
                
                Text(partes.1)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 80, height: 80)
                    )
            }
            
            Text("∧")
                .font(.system(size: 30))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 60, height: 40)
                )
        }
    }
}

struct DisyuncionDiagram: View {
    let partes: (String, String)
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 30) {
                Text(partes.0)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 80, height: 80)
                    )
                
                Text(partes.1)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 80, height: 80)
                    )
            }
            
            Text("∨")
                .font(.system(size: 30))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 60, height: 40)
                )
        }
    }
}

struct ImplicacionDiagram: View {
    let partes: (String, String)
    
    var body: some View {
        HStack(spacing: 20) {
            Text(partes.0)
                .padding()
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                )
            
            Text("→")
                .font(.system(size: 30))
            
            Text(partes.1)
                .padding()
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                )
        }
    }
}

struct EquivalenciaDiagram: View {
    let partes: (String, String)
    
    var body: some View {
        HStack(spacing: 20) {
            Text(partes.0)
                .padding()
                .background(
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 80, height: 80)
                )
            
            Text("↔")
                .font(.system(size: 30))
            
            Text(partes.1)
                .padding()
                .background(
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 80, height: 80)
                )
        }
    }
}

struct DefaultDiagram: View {
    let proposicion: String
    
    var body: some View {
        Text(proposicion)
            .padding()
            .background(
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 150)
            )
    }
}

struct HistorialView: View {
    @Binding var historial: [String]
    @Binding var mostrarHistorial: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(historial.reversed(), id: \.self) { item in
                    Text(item)
                }
                .onDelete { indices in
                    historial.remove(atOffsets: indices)
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
            .navigationTitle("Historial")
        }
    }
}

struct LogicaProposicionalView_Previews: PreviewProvider {
    static var previews: some View {
        LogicaProposicionalView()
    }
}
