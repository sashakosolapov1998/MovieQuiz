//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Александр Косолапов on 11.02.2025.
//

import Foundation
import UIKit

// MARK: - MovieQuizPresenter

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    private let statisticService: StatisticServiceProtocol!
        private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?

        private var currentQuestion: QuizQuestion?
        private let questionsAmount: Int = 10
        private var currentQuestionIndex: Int = 0
        private var correctAnswers: Int = 0

    // MARK: - Initialization
    
    init(viewController: MovieQuizViewControllerProtocol) {
    self.viewController = viewController
    
    statisticService = StatisticService()
    
    questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    viewController.showLoadingIndicator()
    questionFactory?.loadData()
    }
    

    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }

    func didFailToLoadData(with error: Error) {
            let message = error.localizedDescription
            viewController?.showNetworkError(message: message)
        }

    func makeResultsMessage() -> String { // новый метод
        statisticService.store(correct: correctAnswers, total: questionsAmount)

        let bestGame = statisticService.bestGame

        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")

        return resultMessage
    }
    
    // MARK: - FUNC
    private func proceedWithAnswer(isCorrectAnswer: Bool) { // новый метод (было showAnswerResult)
        didAnswer(isCorrectAnswer: isCorrectAnswer) // фиксируем ответ

        viewController?.highlightImageBorder(isCorrectAnswer: isCorrectAnswer) // вызываем UI-метод
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults() // вызываем следующий шаг
        }
    }
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
    func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
        questionFactory?.requestNextQuestion()// обнуляем счётчик при перезапуске викторины
        }
        
    private func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
    private func didAnswer(isCorrectAnswer: Bool) { // новый метод
          if isCorrectAnswer {
              correctAnswers += 1
          }
      }
    
    private func proceedToNextQuestionOrResults() { // новый метод
            if self.isLastQuestion() {
                let text = "Вы ответили на \(correctAnswers) из \(questionsAmount), попробуйте ещё раз!"

                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                
                viewController?.showResults(quiz: viewModel) // исправлено, теперь вызываем через viewController
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion() // исправлено, используем questionFactory
            }
        }
    
    func didReceiveNextQuestion(question: QuizQuestion?) { // новый метод
         guard let question = question else {
             return
         }
         
         currentQuestion = question
         let viewModel = convert(model: question)
         DispatchQueue.main.async { [weak self] in
             self?.viewController?.show(quiz: viewModel)
         }
     }
    
    
     
    func convert(model: QuizQuestion) ->  QuizStepViewModel {
                return QuizStepViewModel(
                       image: UIImage(data: model.image) ?? UIImage(),
                       question: model.text,
                       questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
            }
    
    
    
    // MARK: - Buttons
    func yesButtonClicked(){
        didAnswer(isYes: true)
    
        }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) { // новый метод
            guard let currentQuestion = currentQuestion else {
                return
            }
            
        proceedWithAnswer(isCorrectAnswer: isYes == currentQuestion.correctAnswer)
        }
    
 
}
