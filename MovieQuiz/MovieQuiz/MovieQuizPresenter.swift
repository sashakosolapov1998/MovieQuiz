//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Александр Косолапов on 11.02.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?

    var correctAnswers: Int = 0 // добавлено
    var questionFactory: QuestionFactoryProtocol? // добавлено

   
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
    func resetQuestionIndex() {
            currentQuestionIndex = 0
            correctAnswers = 0 // обнуляем счётчик при перезапуске викторины
        }
        
    func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
    func showNextQuestionOrResults() { // новый метод
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
            
            viewController?.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
        }
    
 
}
