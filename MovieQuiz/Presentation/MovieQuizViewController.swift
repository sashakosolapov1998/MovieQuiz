import UIKit

// MARK: - Controller
// управляет отображением текущего вопроса, реагирует на нажатия кнопок и обновляет интерфейс в зависимости от действий пользователя.
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {


    // MARK: - Outlets
    // Здесь хранятся ссылки на элементы интерфейса, подключённые через Interface Builder (например, imageView, textLabel, counterLabel). Это связывает элементы интерфейса с кодом, позволяя программно обновлять их.
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Properies
    //Здесь объявляются свойства, необходимые для управления состоянием
    //добавляем свойство типа StatisticServiceProtocol
    private var statisticService: StatisticServiceProtocol!
    //массив вопросов викторины вынесли в QuizFactory
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    //добавили alertPresenter
    private var alertPresenter: AlertPresenter!
    
    //индекс текущего вопроса, используемый для отслеживания текущей позиции
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Инициализируем statisticService
        statisticService = StatisticService()
        // Инициализируем AlertPresenter
        alertPresenter = AlertPresenter(viewController: self)
       
        imageView.contentMode = .scaleAspectFill
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
        
        private func convert(model: QuizQuestion) ->  QuizStepViewModel {
            let questionStep = QuizStepViewModel (
                Image: UIImage(named: model.image) ?? UIImage(),
                Question: model.text,
                questionNumber: "\(currentQuestionIndex + 1) /\(questionsAmount)")
            return questionStep
        }
        private func show(quiz step: QuizStepViewModel){
            imageView.image = step.Image
            textLabel.text = step.Question
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in // слабая ссылка на self
                guard let self = self else { return }
                // код который хотим вызвать через 1 секунду
                self.showNextQuestionOrResults()
            }
            
        }
        
        private func showNextQuestionOrResults(){
            
                // Проверяем, не достигли ли конца викторины
                if currentQuestionIndex >= questionsAmount - 1 {
                    let resultsViewModel = QuizResultsViewModel(
                        title: "Конец викторины",
                        text: "Вы ответили правильно на \(correctAnswers) из \(questionsAmount) вопросов",
                        buttonText: "Попробовать снова"
                    )
                    show(quiz: resultsViewModel)
                } else {
                    // Увеличиваем индекс текущего вопроса
                    // Запрашиваем следующий вопрос
                    currentQuestionIndex += 1
                    questionFactory.requestNextQuestion()
                }
            
        }
    
    
    private func show(quiz result: QuizResultsViewModel) {
        //вызываем функцию для сохранения текущего результата в статистике
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        // Данные статистики
        let record = statisticService.bestGame
        let gamesPlayed = statisticService.gamesCount
        let averageAccuracy = statisticService.totalAccuracy
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: record.date)
        
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(gamesPlayed)
        Рекорд: \(record.correct)/\(record.total) \(formattedDate)
        Средняя точность: \(String(format: "%.2f", averageAccuracy))%
        """

        // Создаём модель для AlertPresenter
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
        )
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory.requestNextQuestion()

        // Передаём модель в AlertPresenter
        alertPresenter.showAlert(with: alertModel)
    }
    
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
   
