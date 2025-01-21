//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Александр Косолапов on 11.12.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
