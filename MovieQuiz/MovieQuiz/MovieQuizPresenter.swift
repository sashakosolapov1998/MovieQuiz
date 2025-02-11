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
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
        func resetQuestionIndex() {
            currentQuestionIndex = 0
        }
        
        func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
    
     func convert(model: QuizQuestion) ->  QuizStepViewModel {
                return QuizStepViewModel(
                       image: UIImage(data: model.image) ?? UIImage(),
                       question: model.text,
                       questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
            }
    
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func yesButtonClicked(){
        guard let currentQuestion = currentQuestion else {
                return
            }
            let givenAnswer = true
            
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    
        }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    
    
    
}
