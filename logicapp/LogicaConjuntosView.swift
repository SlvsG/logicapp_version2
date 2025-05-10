import SwiftUI

// MARK: - Main View
struct LogicaConjuntosView: View {
    // Estados para conjuntos
    @State private var conjuntosNumericos: [String] = ["1, 2, 3", "2, 3, 4", "3, 4, 5"]
    @State private var universoNumerico: String = "1, 2, 3, 4, 5, 6, 7, 8, 9, 10"
    @State private var conjuntosAlfabeticos: [String] = ["a, b, c", "b, c, d", "c, d, e"]
    @State private var universoAlfabetico: String = "a, b, c, d, e, f, g, h"
    @State private var operacion: String = "Unión"
    @State private var resultadoNumerico: Set<String> = []
    @State private var resultadoAlfabetico: Set<String> = []
    @State private var mostrarVisualizaciones = true
    @State private var mostrarHistorial = false
    @State private var historial: [String] = []
    @State private var mostrarConfigUniverso = false
    @State private var tipoEntrada = "Numérico"
    
    // Operaciones disponibles
    private let operaciones = [
        "Unión", "Intersección", "Diferencia", "Complemento",
        "Ley de Morgan 1", "Ley de Morgan 2", "Doble Negación",
        "Conmutativa Unión", "Conmutativa Intersección",
        "Asociativa Unión", "Asociativa Intersección",
        "Idempotencia Unión", "Idempotencia Intersección",
        "Contradicción", "Distributiva Unión", "Distributiva Intersección"
    ]
    
    private let tiposEntrada = ["Numérico", "Alfabético"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView()
                    
                    if mostrarConfigUniverso {
                        configuracionUniversoView()
                    }
                    
                    tipoEntradaPickerView()
                    conjuntosInputView()
                    operacionPickerView()
                    actionButtonsView()
                    resultadosView()
                    
                    if mostrarVisualizaciones {
                        visualizacionesView()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Lógica de Conjuntos")
            .sheet(isPresented: $mostrarHistorial) {
                historialView()
            }
        }
    }
    
    // MARK: - Subviews
    
    private func headerView() -> some View {
        HStack {
            Button(action: { mostrarHistorial.toggle() }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .padding(8)
            }
            
            Spacer()
            
            Button(action: { mostrarConfigUniverso.toggle() }) {
                Image(systemName: "globe")
                    .font(.title2)
                    .padding(8)
            }
        }
        .padding(.horizontal)
    }
    
    private func configuracionUniversoView() -> some View {
        VStack {
            if tipoEntrada == "Numérico" {
                HStack {
                    Text("Universo Numérico:")
                    TextField("Ej. 1, 2, 3", text: $universoNumerico)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            } else {
                HStack {
                    Text("Universo Alfabético:")
                    TextField("Ej. a, b, c", text: $universoAlfabetico)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            Button("Aplicar") {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                calcularOperacion()
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func tipoEntradaPickerView() -> some View {
        Picker("Tipo de Conjunto", selection: $tipoEntrada) {
            ForEach(tiposEntrada, id: \.self) { tipo in
                Text(tipo).tag(tipo)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .onChange(of: tipoEntrada) { _ in calcularOperacion() }
    }
    
    private func conjuntosInputView() -> some View {
        Group {
            if tipoEntrada == "Numérico" {
                ForEach(0..<conjuntosNumericos.count, id: \.self) { index in
                    HStack {
                        TextField("Conjunto \(index+1)", text: $conjuntosNumericos[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: conjuntosNumericos[index]) { _ in
                                calcularOperacion()
                            }
                        
                        if conjuntosNumericos.count > 1 {
                            Button(action: {
                                conjuntosNumericos.remove(at: index)
                                calcularOperacion()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                ForEach(0..<conjuntosAlfabeticos.count, id: \.self) { index in
                    HStack {
                        TextField("Conjunto \(index+1)", text: $conjuntosAlfabeticos[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: conjuntosAlfabeticos[index]) { _ in
                                calcularOperacion()
                            }
                        
                        if conjuntosAlfabeticos.count > 1 {
                            Button(action: {
                                conjuntosAlfabeticos.remove(at: index)
                                calcularOperacion()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Button(action: {
                if tipoEntrada == "Numérico" {
                    conjuntosNumericos.append("")
                } else {
                    conjuntosAlfabeticos.append("")
                }
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
    }
    
    private func operacionPickerView() -> some View {
        Menu {
            ForEach(operaciones, id: \.self) { op in
                Button(action: {
                    operacion = op
                    calcularOperacion()
                }) {
                    Text(op)
                }
            }
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
    }
    
    private func actionButtonsView() -> some View {
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
    }
    
    private func resultadosView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Resultados")
                .font(.headline)
            
            if tipoEntrada == "Numérico" {
                Text("Numérico: \(formatearResultado(resultadoNumerico))")
                
                if operacion == "Intersección" && conjuntosNumericos.count >= 2 {
                    mostrarIntersecciones(conjuntos: conjuntosNumericos, resultado: resultadoNumerico)
                }
            } else {
                Text("Alfabético: \(formatearResultado(resultadoAlfabetico))")
                
                if operacion == "Intersección" && conjuntosAlfabeticos.count >= 2 {
                    mostrarIntersecciones(conjuntos: conjuntosAlfabeticos, resultado: resultadoAlfabetico)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func mostrarIntersecciones(conjuntos: [String], resultado: Set<String>) -> some View {
        let sets = conjuntos.map { limpiarConjunto($0) }
        
        ForEach(0..<sets.count, id: \.self) { i in
            ForEach(i+1..<sets.count, id: \.self) { j in
                let interseccion = sets[i].intersection(sets[j])
                if !interseccion.isEmpty {
                    Text("C\(i+1) ∩ C\(j+1) = \(formatearResultado(interseccion))")
                }
            }
        }
        
        if conjuntos.count > 2 {
            let interseccionTotal = sets.reduce(sets[0]) { $0.intersection($1) }
            if !interseccionTotal.isEmpty {
                Text("Intersección total = \(formatearResultado(interseccionTotal))")
                    .bold()
            }
        }
    }
    
    private func visualizacionesView() -> some View {
        VStack(spacing: 30) {
            if tipoEntrada == "Numérico" {
                TablaPertenenciaView(
                    conjuntos: conjuntosNumericos.map { limpiarConjunto($0) },
                    resultado: resultadoNumerico,
                    operacion: operacion,
                    universo: limpiarConjunto(universoNumerico)
                )
                .frame(height: 200)
                
                if conjuntosNumericos.count <= 3 {
                    DiagramaVennView(
                        conjuntos: conjuntosNumericos.map { limpiarConjunto($0) },
                        resultado: resultadoNumerico,
                        operacion: operacion
                    )
                    .frame(height: 250)
                }
            } else {
                TablaPertenenciaView(
                    conjuntos: conjuntosAlfabeticos.map { limpiarConjunto($0) },
                    resultado: resultadoAlfabetico,
                    operacion: operacion,
                    universo: limpiarConjunto(universoAlfabetico)
                )
                .frame(height: 200)
                
                if conjuntosAlfabeticos.count <= 3 {
                    DiagramaVennView(
                        conjuntos: conjuntosAlfabeticos.map { limpiarConjunto($0) },
                        resultado: resultadoAlfabetico,
                        operacion: operacion
                    )
                    .frame(height: 250)
                }
            }
            
            CircuitoLogicoView(operacion: operacion)
                .frame(height: 200)
            
            EcuacionFormalView(operacion: operacion)
                .frame(height: 80)
        }
        .padding()
    }
    
    private func historialView() -> some View {
        NavigationView {
            List {
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
        }
    }
    
    // MARK: - Logic Functions
    
    private func calcularOperacion() {
        if tipoEntrada == "Numérico" {
            calcularOperacionNumerica()
        } else {
            calcularOperacionAlfabetica()
        }
    }
    
    private func calcularOperacionNumerica() {
        guard !conjuntosNumericos.isEmpty else {
            resultadoNumerico = []
            return
        }
        
        let sets = conjuntosNumericos.map { limpiarConjunto($0) }
        let universal = limpiarConjunto(universoNumerico)
        
        switch operacion {
        case "Unión":
            resultadoNumerico = sets.reduce(Set<String>()) { $0.union($1) }
        case "Intersección":
            resultadoNumerico = sets.reduce(sets[0]) { $0.intersection($1) }
        case "Diferencia":
            resultadoNumerico = sets.count >= 2 ? sets[0].subtracting(sets[1]) : Set<String>()
        case "Complemento":
            resultadoNumerico = universal.subtracting(sets.first ?? Set<String>())
        case "Ley de Morgan 1":
            resultadoNumerico = sets.count >= 2 ? universal.subtracting(sets[0].union(sets[1])) : Set<String>()
        case "Ley de Morgan 2":
            resultadoNumerico = sets.count >= 2 ? universal.subtracting(sets[0].intersection(sets[1])) : Set<String>()
        case "Doble Negación":
            resultadoNumerico = universal.subtracting(universal.subtracting(sets.first ?? Set<String>()))
        case "Conmutativa Unión":
            resultadoNumerico = sets.count >= 2 ? sets[1].union(sets[0]) : Set<String>()
        case "Conmutativa Intersección":
            resultadoNumerico = sets.count >= 2 ? sets[1].intersection(sets[0]) : Set<String>()
        case "Asociativa Unión":
            resultadoNumerico = sets.count >= 3 ? sets[0].union(sets[1]).union(sets[2]) :
                         sets.count >= 2 ? sets[0].union(sets[1]) : sets.first ?? Set<String>()
        case "Asociativa Intersección":
            resultadoNumerico = sets.count >= 3 ? sets[0].intersection(sets[1]).intersection(sets[2]) :
                         sets.count >= 2 ? sets[0].intersection(sets[1]) : sets.first ?? Set<String>()
        case "Idempotencia Unión":
            resultadoNumerico = sets.first?.union(sets.first ?? Set<String>()) ?? Set<String>()
        case "Idempotencia Intersección":
            resultadoNumerico = sets.first?.intersection(sets.first ?? Set<String>()) ?? Set<String>()
        case "Contradicción":
            resultadoNumerico = sets.first?.intersection(universal.subtracting(sets.first ?? Set<String>())) ?? Set<String>()
        case "Distributiva Unión":
            resultadoNumerico = sets.count >= 3 ? sets[0].union(sets[1].intersection(sets[2])) : Set<String>()
        case "Distributiva Intersección":
            resultadoNumerico = sets.count >= 3 ? sets[0].intersection(sets[1].union(sets[2])) : Set<String>()
        default:
            resultadoNumerico = []
        }
        
        let conjuntosStr = conjuntosNumericos.enumerated().map { "\($0+1)=\($1)" }.joined(separator: ", ")
        let entrada = "[Num] \(operacion): \(conjuntosStr) → \(formatearResultado(resultadoNumerico))"
        if !historial.contains(entrada) {
            historial.append(entrada)
        }
    }
    
    private func calcularOperacionAlfabetica() {
        guard !conjuntosAlfabeticos.isEmpty else {
            resultadoAlfabetico = []
            return
        }
        
        let sets = conjuntosAlfabeticos.map { limpiarConjunto($0) }
        let universal = limpiarConjunto(universoAlfabetico)
        
        switch operacion {
        case "Unión":
            resultadoAlfabetico = sets.reduce(Set<String>()) { $0.union($1) }
        case "Intersección":
            resultadoAlfabetico = sets.reduce(sets[0]) { $0.intersection($1) }
        case "Diferencia":
            resultadoAlfabetico = sets.count >= 2 ? sets[0].subtracting(sets[1]) : Set<String>()
        case "Complemento":
            resultadoAlfabetico = universal.subtracting(sets.first ?? Set<String>())
        case "Ley de Morgan 1":
            resultadoAlfabetico = sets.count >= 2 ? universal.subtracting(sets[0].union(sets[1])) : Set<String>()
        case "Ley de Morgan 2":
            resultadoAlfabetico = sets.count >= 2 ? universal.subtracting(sets[0].intersection(sets[1])) : Set<String>()
        case "Doble Negación":
            resultadoAlfabetico = universal.subtracting(universal.subtracting(sets.first ?? Set<String>()))
        case "Conmutativa Unión":
            resultadoAlfabetico = sets.count >= 2 ? sets[1].union(sets[0]) : Set<String>()
        case "Conmutativa Intersección":
            resultadoAlfabetico = sets.count >= 2 ? sets[1].intersection(sets[0]) : Set<String>()
        case "Asociativa Unión":
            resultadoAlfabetico = sets.count >= 3 ? sets[0].union(sets[1]).union(sets[2]) :
                         sets.count >= 2 ? sets[0].union(sets[1]) : sets.first ?? Set<String>()
        case "Asociativa Intersección":
            resultadoAlfabetico = sets.count >= 3 ? sets[0].intersection(sets[1]).intersection(sets[2]) :
                         sets.count >= 2 ? sets[0].intersection(sets[1]) : sets.first ?? Set<String>()
        case "Idempotencia Unión":
            resultadoAlfabetico = sets.first?.union(sets.first ?? Set<String>()) ?? Set<String>()
        case "Idempotencia Intersección":
            resultadoAlfabetico = sets.first?.intersection(sets.first ?? Set<String>()) ?? Set<String>()
        case "Contradicción":
            resultadoAlfabetico = sets.first?.intersection(universal.subtracting(sets.first ?? Set<String>())) ?? Set<String>()
        case "Distributiva Unión":
            resultadoAlfabetico = sets.count >= 3 ? sets[0].union(sets[1].intersection(sets[2])) : Set<String>()
        case "Distributiva Intersección":
            resultadoAlfabetico = sets.count >= 3 ? sets[0].intersection(sets[1].union(sets[2])) : Set<String>()
        default:
            resultadoAlfabetico = []
        }
        
        let conjuntosStr = conjuntosAlfabeticos.enumerated().map { "\($0+1)=\($1)" }.joined(separator: ", ")
        let entrada = "[Alf] \(operacion): \(conjuntosStr) → \(formatearResultado(resultadoAlfabetico))"
        if !historial.contains(entrada) {
            historial.append(entrada)
        }
    }
    
    private func borrarCampos() {
        if tipoEntrada == "Numérico" {
            conjuntosNumericos = ["", ""]
            resultadoNumerico = []
        } else {
            conjuntosAlfabeticos = ["", ""]
            resultadoAlfabetico = []
        }
        operacion = "Unión"
    }
    
    private func limpiarConjunto(_ texto: String) -> Set<String> {
        Set(texto.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty })
    }
    
    private func formatearResultado(_ conjunto: Set<String>) -> String {
        conjunto.isEmpty ? "∅" : "{\(conjunto.sorted().joined(separator: ", "))}"
    }
}

// MARK: - Auxiliary Views

struct TablaPertenenciaView: View {
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

struct DiagramaVennView: View {
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

struct CircuitoLogicoView: View {
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

struct EcuacionFormalView: View {
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

// MARK: - Preview
struct LogicaConjuntosView_Previews: PreviewProvider {
    static var previews: some View {
        LogicaConjuntosView()
    }
}
