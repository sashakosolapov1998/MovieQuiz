//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests.swift
//
//  Created by Александр Косолапов on 13.02.2025.
//

import XCTest

import XCTest
@testable import MovieQuiz

// MARK: - Mock View Controller

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func showResults(quiz result: QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}

// MARK: - Presenter Tests

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // Arrange
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        // Act
        let viewModel = sut.convert(model: question)
        
        // Assert
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
