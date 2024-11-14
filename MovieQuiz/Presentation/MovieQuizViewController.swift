import UIKit

// MARK: - Controller
// управляет отображением текущего вопроса, реагирует на нажатия кнопок и обновляет интерфейс в зависимости от действий пользователя.
final class MovieQuizViewController: UIViewController {
    
    
    // MARK: - Outlets
    // Здесь хранятся ссылки на элементы интерфейса, подключённые через Interface Builder (например, imageView, textLabel, counterLabel). Это связывает элементы интерфейса с кодом, позволяя программно обновлять их.
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabek: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Properies
    //Здесь объявляются свойства, необходимые для управления состоянием
    
    //массив вопросов викторины
    private let questions: [QuizQuestion] = [
        .init(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        .init(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        .init(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        .init(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        .init(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        .init(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        .init(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        .init(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        .init(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        .init(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    //индекс текущего вопроса, используемый для отслеживания текущей позиции
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFill
        
        
        // Отображаем первый вопрос при запуске
        let firstQuestion = questions[currentQuestionIndex]
        let firstQuestionViewModel = convert(model: firstQuestion)
        show(quiz: firstQuestionViewModel)
    }
    
    
    // MARK: - Methods
    private func convert(model: QuizQuestion) ->  QuizStepViewModel {
        let questionStep = QuizStepViewModel (
            Image: UIImage(named: model.image) ?? UIImage(),
            Question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) /\(questions.count)")
        return questionStep
    }
    private func show(quiz step: QuizStepViewModel){
        imageView.image = step.Image
        textLabek.text = step.Question
        counterLabel.text = step.questionNumber
       
        // Сбрасываем цвет рамки на прозрачный при показе нового вопроса
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        
        // запускаем задачу через 1 секунду с помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // код который хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
     
    }
    
    private func showNextQuestionOrResults(){
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10" // 1
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            // идем в состояние "Результат квиза"
        } else { // 2
            currentQuestionIndex += 1}
        // идем  состояние "Вопрос показан"
        
        let nextQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: nextQuestion)
        
        show(quiz: viewModel)
    }
    
    private func show(quiz result: QuizResultsViewModel){
        
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Structures data (MODEL)
    //отвечает за описание данных, с которыми работает приложение. Она содержит структуры и классы для хранения информации.
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    // MARK: - View Model
    //структура, созданная для подготовки данных, которые будут отображаться в интерфейсе
    struct QuizStepViewModel {
        let Image : UIImage
        let Question : String
        let questionNumber : String
    }
    // для состояния "Результат квиза"
    struct QuizResultsViewModel {
        // строка с заголовком алерта
        let title: String
        // строка с текстом о количестве набранных очков
        let text: String
        // текст для кнопки алерта
        let buttonText: String
    }
    
        
    /*
     Mock-данные
     
     
     Картинка: The Godfather
     Настоящий рейтинг: 9,2
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: The Dark Knight
     Настоящий рейтинг: 9
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: Kill Bill
     Настоящий рейтинг: 8,1
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: The Avengers
     Настоящий рейтинг: 8
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: Deadpool
     Настоящий рейтинг: 8
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: The Green Knight
     Настоящий рейтинг: 6,6
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: Old
     Настоящий рейтинг: 5,8
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: НЕТ
     
     
     Картинка: The Ice Age Adventures of Buck Wild
     Настоящий рейтинг: 4,3
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: НЕТ
     
     
     Картинка: Tesla
     Настоящий рейтинг: 5,1
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: НЕТ
     
     
     Картинка: Vivarium
     Настоящий рейтинг: 5,8
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: НЕТ
     */
}
