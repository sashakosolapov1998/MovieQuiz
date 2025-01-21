//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Александр Косолапов on 26.11.2024.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    
    private let questions : [QuizQuestion] = [
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
    
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
        
    }
}
















