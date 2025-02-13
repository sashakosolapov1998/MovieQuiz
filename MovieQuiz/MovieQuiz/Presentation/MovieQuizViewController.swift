import UIKit

    // MARK: - Controller
    // управляет отображением текущего вопроса, реагирует на нажатия кнопок и обновляет интерфейс в зависимости от действий пользователя.
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    // MARK: - Outlets
    // Здесь хранятся ссылки на элементы интерфейса, подключённые через Interface Builder (например, imageView, textLabel, counterLabel). Это связывает элементы интерфейса с кодом, позволяя программно обновлять их.
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        
        // Инициализируем statisticService
        statisticService = StatisticService()
        // Инициализируем AlertPresenter
        alertPresenter = AlertPresenter(viewController: self)
        
        imageView.contentMode = .scaleAspectFill
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private functions
    
    func didReceiveNextQuestion(question: QuizQuestion?) { // изменено
        presenter.didReceiveNextQuestion(question: question)
    }
    func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        // Сбрасываем цвет рамки на прозрачный при показе нового вопроса
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        
        // запускаем задачу через 1 секунду с помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in guard let self = self else { return }
            self.presenter.questionFactory = self.questionFactory // исправлено, передаём в Presenter
            self.presenter.showNextQuestionOrResults()
        }
        
    }
    
    
    func showResults(quiz result: QuizResultsViewModel) {
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            
            // Данные статистики
            let record = statisticService.bestGame
            let gamesPlayed = statisticService.gamesCount
            let averageAccuracy = statisticService.totalAccuracy
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let formattedDate = dateFormatter.string(from: record.date)
            
            let message = """
            Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
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
                    self.presenter.restartGame()
                    presenter.restartGame()
                    self.questionFactory.requestNextQuestion()
                }
            )
            
            // Передаём модель в AlertPresenter
            alertPresenter.showAlert(with: alertModel)
        }
    }
    // MARK: - Properies
    //Здесь объявляются свойства, необходимые для управления состоянием
    
    //Показываем индикатор загрузки и его состояния
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    //Скрываем индикатор загрузки
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    //Алерт с ошибкой
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            //presenter.restartGame()
            
            self.questionFactory.requestNextQuestion()
        }
        
        alertPresenter.showAlert(with: model)
    }
    
    //добавляем свойство типа StatisticServiceProtocol
    private var statisticService: StatisticServiceProtocol!
    //массив вопросов викторины вынесли в QuizFactory
    
    private var questionFactory: QuestionFactoryProtocol!
    
    
    //добавили alertPresenter
    private var alertPresenter: AlertPresenter!
    
    private var presenter = MovieQuizPresenter()
    
    
    
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
}

        
    
