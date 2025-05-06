// Carlos Angel Selvas Gomez.

import SwiftUI

struct ContentView: View {
    @State private var mostrarInstructivo = false
    @State private var movingImages: [MovingImage] = []
    @State private var mostrarInformacion = false
    
    struct MovingImage {
        var id = UUID()
        var position: CGPoint
        var angle: Double
        var speed: Double
        var direction: CGPoint
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con imagen de ajedrez
                Image("ajedrez")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.3))
                    .edgesIgnoringSafeArea(.all)
                
                // Varias imágenes animadas
                ForEach(movingImages, id: \.id) { image in
                    Image("pieza")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(image.angle))
                        .position(image.position)
                }
                
                // Contenido principal
                VStack {
                    // Botón de instructivo en la parte superior derecha
                    HStack {
                        Spacer()
                        Button(action: {
                            mostrarInstructivo.toggle()
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.trailing, 20)
                                .padding(.top, 10)
                        }
                    }
                    
                    Spacer()
                    
                    // Título
                    Text("Logicapp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 80)
                    
                    // Cuadros de selección en forma de grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 80) {
                        // Lógica de Conjuntos
                        NavigationLink(destination: LogicaConjuntosView()) {
                            MenuCard(
                                icon: "square.stack.3d.up.fill",
                                title: "Lógica de Conjuntos",
                                color: .blue
                            )
                        }
                        
                        // Lógica Proposicional
                        NavigationLink(destination: LogicaProposicionalView()) {
                            MenuCard(
                                icon: "function",
                                title: "Lógica Proposicional",
                                color: .green
                            )
                        }
                        
                        // Lógica Booleana
                        NavigationLink(destination: BooleanLogicView()) {
                            MenuCard(
                                icon: "chart.bar.fill",
                                title: "Lógica Booleana",
                                color: .orange
                            )
                        }
                        
                        // Nuevo botón de Relación
                        NavigationLink(destination: DigitalLogicView()) {
                            MenuCard(
                                icon: "arrow.triangle.merge",
                                title: "Relación",
                                color: .red
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Imagen JPG para información
                    Button(action: {
                        mostrarInformacion.toggle()
                    }) {
                        Image("tec")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .padding(.bottom, 20)
                    }
                }
                
                // Modal de Instructivo
                if mostrarInstructivo {
                    InstructivoView(mostrarInstructivo: $mostrarInstructivo)
                }
                
                // Modal de Información
                if mostrarInformacion {
                    InformacionAlumnoView(mostrarInformacion: $mostrarInformacion)
                }
            }
            .onAppear {
                setupMovingImages()
                startAnimationTimer()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func setupMovingImages() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for _ in 0..<8 {
            movingImages.append(MovingImage(
                position: CGPoint(
                    x: CGFloat.random(in: 50...screenWidth-50),
                    y: CGFloat.random(in: 50...screenHeight-50)
                ),
                angle: 0,
                speed: Double.random(in: 0.5...2.0),
                direction: CGPoint(
                    x: CGFloat.random(in: -1...1),
                    y: CGFloat.random(in: -1...1)
                ).normalized()
            ))
        }
    }
    
    func startAnimationTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            updateMovingImages()
        }
    }
    
    func updateMovingImages() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for index in movingImages.indices {
            var newPosition = movingImages[index].position
            newPosition.x += CGFloat(movingImages[index].speed) * movingImages[index].direction.x
            newPosition.y += CGFloat(movingImages[index].speed) * movingImages[index].direction.y
            
            if newPosition.x < 30 || newPosition.x > screenWidth - 30 {
                movingImages[index].direction.x *= -1
            }
            if newPosition.y < 30 || newPosition.y > screenHeight - 30 {
                movingImages[index].direction.y *= -1
            }
            
            var newAngle = movingImages[index].angle + movingImages[index].speed
            if newAngle > 360 { newAngle -= 360 }
            
            movingImages[index].position = newPosition
            movingImages[index].angle = newAngle
        }
    }
}

struct InformacionAlumnoView: View {
    @Binding var mostrarInformacion: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    mostrarInformacion = false
                }
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        mostrarInformacion = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Información del Alumno")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    HStack {
                        Text("Nombre:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, alignment: .leading)
                        Text("Carlos Angel Selvas Gomez")
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Número de control:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, alignment: .leading)
                        Text("19270181")
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Carrera:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, alignment: .leading)
                        Text("Ingeniería en desarrollo de software")
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Asesor:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, alignment: .leading)
                        Text("Roberto Cruz Gordillo")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
            }
            .padding(25)
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)))
            .cornerRadius(20)
        }
        .transition(.opacity)
        .zIndex(1)
    }
}

struct MenuCard: View {
    let icon: String
    let title: String
    let color: Color
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(width: 150, height: 150)
        .background(color.opacity(isAnimating ? 0.9 : 0.8))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(isAnimating ? 0.6 : 0.3), lineWidth: isAnimating ? 2 : 1)
        )
        .shadow(color: color.opacity(isAnimating ? 0.6 : 0.4), radius: isAnimating ? 15 : 10, x: 0, y: isAnimating ? 8 : 5)
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever()) {
                isAnimating = true
            }
        }
    }
}

struct InstructivoView: View {
    @Binding var mostrarInstructivo: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    mostrarInstructivo = false
                }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Button(action: {
                            mostrarInstructivo = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Lógica de Conjuntos").font(.title2).bold().foregroundColor(.white)
                        Text("Cómo usar:").font(.headline).foregroundColor(.white)
                        Text("• Ingresa elementos separados por comas (ej: 1, 2, 3)").foregroundColor(.white)
                        Text("• Selecciona una operación del menú").foregroundColor(.white)
                        Text("• Ejemplos válidos:").font(.headline).foregroundColor(.white)
                        Text("  - Unión: 1, 2, 3 ∪ 2, 3, 4 = {1, 2, 3, 4}").foregroundColor(.white)
                        Text("  - Intersección: 1, 2 ∩ 2, 3 = {2}").foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Lógica Proposicional").font(.title2).bold().foregroundColor(.white)
                        Text("Cómo usar:").font(.headline).foregroundColor(.white)
                        Text("• Usa conectores lógicos: ∧ (y), ∨ (o), → (implica), ¬ (no)").foregroundColor(.white)
                        Text("• Variables proposicionales: P, Q, R, etc.").foregroundColor(.white)
                        Text("• Ejemplos válidos:").font(.headline).foregroundColor(.white)
                        Text("  - P ∧ Q → R").foregroundColor(.white)
                        Text("  - ¬(P ∨ Q) ↔ (¬P ∧ ¬Q)").foregroundColor(.white)
                        Text("  - (P → Q) ∧ (Q → R) → (P → R)").foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    
                    // SECCIÓN AÑADIDA PARA LÓGICA BOOLEANA
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Lógica Booleana").font(.title2).bold().foregroundColor(.white)
                        Text("Cómo usar:").font(.headline).foregroundColor(.white)
                        Text("• Usa operadores booleanos: & (AND), | (OR), ^ (XOR), ~ (NOT)").foregroundColor(.white)
                        Text("• Variables booleanas: A, B, C, etc. o 1/0 para verdadero/falso").foregroundColor(.white)
                        Text("• Ejemplos válidos:").font(.headline).foregroundColor(.white)
                        Text("  - A & B | C").foregroundColor(.white)
                        Text("  - ~(A | B) ↔ (~A & ~B) (Ley de De Morgan)").foregroundColor(.white)
                        Text("  - (A & B) ^ (A | C)").foregroundColor(.white)
                        Text("• Las tablas de verdad muestran 1 (verdadero) y 0 (falso)").foregroundColor(.white)
                        Text("• Puedes evaluar propiedades como identidad, dominación, etc.").foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(25)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7)
            .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)))
            .cornerRadius(20)
        }
        .transition(.opacity)
        .zIndex(1)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

extension CGPoint {
    func normalized() -> CGPoint {
        let length = sqrt(x * x + y * y)
        return length > 0 ? CGPoint(x: x / length, y: y / length) : .zero
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
