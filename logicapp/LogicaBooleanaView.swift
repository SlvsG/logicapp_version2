import SwiftUI

// MARK: - Main View
struct BooleanLogicView: View {
    @State private var expression: String = "A & B"
    @State private var operation: String = "Evaluation"
    @State private var result: String = ""
    @State private var showVisualizations: Bool = true
    @State private var showHistory: Bool = false
    @State private var history: [String] = []
    
    let operations = [
        "Evaluation",
        "NOT",
        "AND",
        "OR",
        "XOR",
        "NAND",
        "NOR",
        "XNOR",
        "De Morgan's Laws",
        "Distributive Property",
        "Associative Property",
        "Commutative Property",
        "Identity",
        "Domination",
        "Idempotence",
        "Double Negation",
        "Absorption",
        "Complement"
    ]
    
    let symbols = ["&", "|", "^", "~", "(", ")", "0", "1"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { showHistory.toggle() }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .padding(8)
                        }
                        
                        Spacer()
                        
                        Text("Boolean Logic")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .padding(8)
                            .opacity(0)
                    }
                    .padding(.horizontal)
                    
                    // Input field
                    TextField("Expression (e.g., A & B)", text: $expression)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Operation picker
                    Picker("Operation", selection: $operation) {
                        ForEach(operations, id: \.self) { op in
                            Text(op).tag(op)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    // Action buttons
                    HStack(spacing: 15) {
                        Button(action: evaluateExpression) {
                            Text("Evaluate")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: clearFields) {
                            Text("Clear")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Result
                    Text("Result: \(result)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    // Visualizations
                    if showVisualizations {
                        VStack(spacing: 30) {
                            TruthTableView(
                                expression: expression,
                                operation: operation
                            )
                            .frame(height: 300)
                            
                            EquationView(
                                expression: expression,
                                operation: operation
                            )
                            .frame(height: 80)
                            
                            LogicCircuitView(
                                expression: expression,
                                operation: operation
                            )
                            .frame(height: 250)
                        }
                        .padding()
                        .transition(.slide)
                    }
                }
                .padding(.vertical)
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(history: $history, showHistory: $showHistory)
            }
            .navigationTitle("Boolean Logic")
            .animation(.easeInOut, value: showVisualizations)
        }
    }
    
    private func evaluateExpression() {
        switch operation {
        case "Evaluation":
            result = "Evaluating: \(expression)"
        case "NOT":
            result = "~\(expression)"
        case "AND":
            result = "\(expression) AND operation"
        case "OR":
            result = "\(expression) OR operation"
        case "XOR":
            result = "\(expression) XOR operation"
        case "NAND":
            result = "NOT (\(expression) AND)"
        case "NOR":
            result = "NOT (\(expression) OR)"
        case "XNOR":
            result = "NOT (\(expression) XOR)"
        case "De Morgan's Laws":
            if expression.contains("&") {
                let parts = expression.components(separatedBy: " & ")
                result = "~\(parts[0]) | ~\(parts[1])"
            } else if expression.contains("|") {
                let parts = expression.components(separatedBy: " | ")
                result = "~\(parts[0]) & ~\(parts[1])"
            }
        case "Distributive Property":
            result = "Distributive property applied to: \(expression)"
        case "Associative Property":
            result = "Associative property applied to: \(expression)"
        case "Commutative Property":
            result = "Commutative property applied to: \(expression)"
        case "Identity":
            result = "A & 1 = A, A | 0 = A"
        case "Domination":
            result = "A & 0 = 0, A | 1 = 1"
        case "Idempotence":
            result = "\(expression) & \(expression) = \(expression)"
        case "Double Negation":
            result = "~~\(expression) = \(expression)"
        case "Absorption":
            result = "A & (A | B) = A, A | (A & B) = A"
        case "Complement":
            result = "A & ~A = 0, A | ~A = 1"
        default:
            result = "Operation \(operation) applied"
        }
        
        let entry = "\(operation): \(expression) → \(result)"
        if !history.contains(entry) {
            history.append(entry)
        }
    }
    
    private func clearFields() {
        expression = ""
        result = ""
        operation = "Evaluation"
    }
}

// MARK: - Truth Table View
struct TruthTableView: View {
    let expression: String
    let operation: String
    
    private var variables: [String] {
        var vars = Set<String>()
        let pattern = "[A-Z]"
        let regex = try? NSRegularExpression(pattern: pattern)
        
        let range = NSRange(location: 0, length: expression.utf16.count)
        regex?.enumerateMatches(in: expression, range: range) { match, _, _ in
            if let matchRange = match?.range, let range = Range(matchRange, in: expression) {
                vars.insert(String(expression[range]))
            }
        }
        
        return Array(vars).sorted()
    }
    
    private var combinations: [[String: Bool]] {
        let n = variables.count
        var comb = [[String: Bool]]()
        
        for i in 0..<(1 << n) {
            var combination = [String: Bool]()
            for j in 0..<n {
                combination[variables[j]] = (i & (1 << j)) != 0
            }
            comb.append(combination)
        }
        
        return comb
    }
    
    var body: some View {
        VStack {
            Text("Truth Table")
                .font(.headline)
            
            ScrollView(.horizontal) {
                HStack(spacing: 1) {
                    // Column headers
                    ForEach(variables, id: \.self) { variable in
                        Text(variable)
                            .frame(width: 50)
                            .padding(8)
                            .background(Color.blue.opacity(0.5))
                            .foregroundColor(.white)
                    }
                    
                    Text(expression)
                        .frame(width: 100)
                        .padding(8)
                        .background(Color.blue.opacity(0.5))
                        .foregroundColor(.white)
                    
                    Text("Result")
                        .frame(width: 100)
                        .padding(8)
                        .background(Color.green.opacity(0.5))
                        .foregroundColor(.white)
                }
                
                // Data rows
                ForEach(0..<combinations.count, id: \.self) { index in
                    HStack(spacing: 1) {
                        ForEach(variables, id: \.self) { variable in
                            Text(combinations[index][variable, default: false] ? "1" : "0")
                                .frame(width: 50)
                                .padding(8)
                                .background(index % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.2))
                        }
                        
                        Text(evaluate(expression, with: combinations[index]) ? "1" : "0")
                            .frame(width: 100)
                            .padding(8)
                            .background(index % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.2))
                        
                        Text(evaluateOperation(with: combinations[index]) ? "1" : "0")
                            .frame(width: 100)
                            .padding(8)
                            .background(index % 2 == 0 ? Color.green.opacity(0.1) : Color.green.opacity(0.2))
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func evaluate(_ expr: String, with values: [String: Bool]) -> Bool {
        let cleanExpr = expr
            .replacingOccurrences(of: " & ", with: "&")
            .replacingOccurrences(of: " | ", with: "|")
            .replacingOccurrences(of: " ^ ", with: "^")
            .replacingOccurrences(of: " ~ ", with: "~")
        
        if cleanExpr.contains("&") {
            let parts = cleanExpr.components(separatedBy: "&")
            return evaluateVariable(parts[0], with: values) && evaluateVariable(parts[1], with: values)
        } else if cleanExpr.contains("|") {
            let parts = cleanExpr.components(separatedBy: "|")
            return evaluateVariable(parts[0], with: values) || evaluateVariable(parts[1], with: values)
        } else if cleanExpr.contains("^") {
            let parts = cleanExpr.components(separatedBy: "^")
            return evaluateVariable(parts[0], with: values) != evaluateVariable(parts[1], with: values)
        } else if cleanExpr.contains("~") {
            let variable = cleanExpr.replacingOccurrences(of: "~", with: "")
            return !evaluateVariable(variable, with: values)
        } else {
            return evaluateVariable(expr, with: values)
        }
    }
    
    private func evaluateVariable(_ variable: String, with values: [String: Bool]) -> Bool {
        let cleanVar = variable
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        if cleanVar == "1" { return true }
        if cleanVar == "0" { return false }
        return values[cleanVar] ?? false
    }
    
    private func evaluateOperation(with values: [String: Bool]) -> Bool {
        switch operation {
        case "NOT":
            return !evaluate(expression, with: values)
        case "NAND":
            return !(evaluate(expression, with: values))
        case "NOR":
            return !evaluate(expression, with: values)
        case "XNOR":
            return evaluate(expression, with: values) == true
        case "De Morgan's Laws":
            if expression.contains("&") {
                let parts = expression.components(separatedBy: " & ")
                return !evaluateVariable(parts[0], with: values) || !evaluateVariable(parts[1], with: values)
            } else if expression.contains("|") {
                let parts = expression.components(separatedBy: " | ")
                return !evaluateVariable(parts[0], with: values) && !evaluateVariable(parts[1], with: values)
            }
            return false
        case "Complement":
            return evaluate(expression, with: values) && !evaluate(expression, with: values)
        default:
            return evaluate(expression, with: values)
        }
    }
}

// MARK: - Equation View
struct EquationView: View {
    let expression: String
    let operation: String
    
    var body: some View {
        VStack {
            Text("Boolean Equation")
                .font(.headline)
            
            Text("\(operationSymbol())\(expression)")
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
    
    private func operationSymbol() -> String {
        switch operation {
        case "NOT": return "~"
        case "AND": return "& "
        case "OR": return "| "
        case "XOR": return "^ "
        default: return ""
        }
    }
}

// MARK: - Logic Circuit View
struct LogicCircuitView: View {
    let expression: String
    let operation: String
    
    var body: some View {
        VStack {
            Text("Logic Circuit")
                .font(.headline)
            
            ZStack {
                if operation == "NOT" {
                    NOTGate(expression: expression)
                } else if expression.contains("&") {
                    if let parts = separateExpression(expression, operator: "&") {
                        ANDGate(inputs: parts)
                    } else {
                        DefaultGate(expression: expression)
                    }
                } else if expression.contains("|") {
                    if let parts = separateExpression(expression, operator: "|") {
                        ORGate(inputs: parts)
                    } else {
                        DefaultGate(expression: expression)
                    }
                } else if expression.contains("^") {
                    if let parts = separateExpression(expression, operator: "^") {
                        XORGate(inputs: parts)
                    } else {
                        DefaultGate(expression: expression)
                    }
                } else {
                    DefaultGate(expression: expression)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func separateExpression(_ expr: String, operator: String) -> (String, String)? {
        let parts = expr.components(separatedBy: " \(`operator`) ")
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }
}

// MARK: - Logic Gate Views
struct NOTGate: View {
    let expression: String
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color.red.opacity(0.2))
                .frame(width: 100)
                .overlay(Text(expression))
            
            Triangle()
                .fill(Color.black)
                .frame(width: 30, height: 20)
                .offset(y: 10)
            
            Circle()
                .stroke(Color.black)
                .frame(width: 10)
                .offset(y: 10)
        }
    }
}

struct ANDGate: View {
    let inputs: (String, String)
    
    var body: some View {
        Group {
            // Inputs
            Text(inputs.0)
                .offset(x: -60, y: -30)
            Text(inputs.1)
                .offset(x: -60, y: 30)
            
            // Input lines
            Path { path in
                path.move(to: CGPoint(x: -50, y: -30))
                path.addLine(to: CGPoint(x: -20, y: -30))
                
                path.move(to: CGPoint(x: -50, y: 30))
                path.addLine(to: CGPoint(x: -20, y: 30))
            }
            .stroke(Color.black, lineWidth: 2)
            
            // AND gate shape
            Path { path in
                path.move(to: CGPoint(x: -20, y: -40))
                path.addLine(to: CGPoint(x: 20, y: -40))
                path.addArc(center: CGPoint(x: 20, y: 0), radius: 40, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
                path.addLine(to: CGPoint(x: -20, y: 40))
                path.addLine(to: CGPoint(x: -20, y: -40))
            }
            .fill(Color.blue.opacity(0.2))
            .stroke(Color.black, lineWidth: 2)
            
            // Output line
            Path { path in
                path.move(to: CGPoint(x: 60, y: 0))
                path.addLine(to: CGPoint(x: 80, y: 0))
            }
            .stroke(Color.black, lineWidth: 2)
            
            Text("AND")
                .offset(y: -50)
        }
    }
}

struct ORGate: View {
    let inputs: (String, String)
    
    var body: some View {
        Group {
            // Inputs
            Text(inputs.0)
                .offset(x: -60, y: -30)
            Text(inputs.1)
                .offset(x: -60, y: 30)
            
            // Input lines
            Path { path in
                path.move(to: CGPoint(x: -50, y: -30))
                path.addLine(to: CGPoint(x: -10, y: -30))
                
                path.move(to: CGPoint(x: -50, y: 30))
                path.addLine(to: CGPoint(x: -10, y: 30))
            }
            .stroke(Color.black, lineWidth: 2)
            
            // OR gate shape
            Path { path in
                path.move(to: CGPoint(x: -10, y: -30))
                path.addQuadCurve(to: CGPoint(x: 10, y: 0), control: CGPoint(x: -30, y: -15))
                path.addQuadCurve(to: CGPoint(x: -10, y: 30), control: CGPoint(x: -30, y: 15))
                path.addLine(to: CGPoint(x: 30, y: 30))
                path.addQuadCurve(to: CGPoint(x: 30, y: -30), control: CGPoint(x: 50, y: 0))
                path.addLine(to: CGPoint(x: -10, y: -30))
            }
            .fill(Color.green.opacity(0.2))
            .stroke(Color.black, lineWidth: 2)
            
            // Output line
            Path { path in
                path.move(to: CGPoint(x: 60, y: 0))
                path.addLine(to: CGPoint(x: 80, y: 0))
            }
            .stroke(Color.black, lineWidth: 2)
            
            Text("OR")
                .offset(y: -50)
        }
    }
}

struct XORGate: View {
    let inputs: (String, String)
    
    var body: some View {
        Group {
            // Inputs
            Text(inputs.0)
                .offset(x: -70, y: -30)
            Text(inputs.1)
                .offset(x: -70, y: 30)
            
            // Input lines
            Path { path in
                path.move(to: CGPoint(x: -60, y: -30))
                path.addLine(to: CGPoint(x: -10, y: -30))
                
                path.move(to: CGPoint(x: -60, y: 30))
                path.addLine(to: CGPoint(x: -10, y: 30))
            }
            .stroke(Color.black, lineWidth: 2)
            
            // XOR gate shape (OR with extra curve)
            Path { path in
                // Extra curve
                path.move(to: CGPoint(x: -20, y: -30))
                path.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: -40, y: -15))
                path.addQuadCurve(to: CGPoint(x: -20, y: 30), control: CGPoint(x: -40, y: 15))
                
                // Main OR shape
                path.move(to: CGPoint(x: -10, y: -30))
                path.addQuadCurve(to: CGPoint(x: 10, y: 0), control: CGPoint(x: -30, y: -15))
                path.addQuadCurve(to: CGPoint(x: -10, y: 30), control: CGPoint(x: -30, y: 15))
                path.addLine(to: CGPoint(x: 30, y: 30))
                path.addQuadCurve(to: CGPoint(x: 30, y: -30), control: CGPoint(x: 50, y: 0))
                path.addLine(to: CGPoint(x: -10, y: -30))
            }
            .fill(Color.purple.opacity(0.2))
            .stroke(Color.black, lineWidth: 2)
            
            // Output line
            Path { path in
                path.move(to: CGPoint(x: 60, y: 0))
                path.addLine(to: CGPoint(x: 80, y: 0))
            }
            .stroke(Color.black, lineWidth: 2)
            
            Text("XOR")
                .offset(y: -50)
        }
    }
}

struct DefaultGate: View {
    let expression: String
    
    var body: some View {
        Circle()
            .fill(Color.purple.opacity(0.2))
            .frame(width: 150)
            .overlay(Text(expression))
    }
}

// MARK: - Shape for NOT gate triangle
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - History View
struct HistoryView: View {
    @Binding var history: [String]
    @Binding var showHistory: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(history.reversed(), id: \.self) { item in
                    Text(item)
                }
                .onDelete { indices in
                    history.remove(atOffsets: indices)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        history.removeAll()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        showHistory = false
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

// MARK: - Preview
struct BooleanLogicView_Previews: PreviewProvider {
    static var previews: some View {
        BooleanLogicView()
    }
}
