//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Александр Косолапов on 10.02.2025.
@testable import MovieQuiz // импортируем приложение для тестирования
import XCTest // не забывайте импортировать фреймворк для тестирования

class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    // Новый тест: проверка появления алерта при завершении игры
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2) // Даем UI время обновиться
        }
        
        print(app.debugDescription) // Проверить структуру элементов в консоли

        let alert = app.alerts.firstMatch // Берем первый найденный алерт

        XCTAssertTrue(alert.waitForExistence(timeout: 10), "Алерт не появился") // Увеличен таймаут ожидания
        XCTAssertEqual(alert.label, "Этот раунд окончен!", "Неверный заголовок алерта")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз", "Неверный текст на кнопке алерта")
    }
    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2) // Даем UI время обновиться
        }
        
        let alert = app.alerts.firstMatch // Берем первый найденный алерт
        
        XCTAssertTrue(alert.waitForExistence(timeout: 10), "Алерт не появился") // Ждем появления алерта
        
        alert.buttons.firstMatch.tap() // Закрываем алерт
        
        XCTAssertFalse(alert.waitForExistence(timeout: 3), "Алерт не исчез") // Проверяем, что алерт исчез

        sleep(2) // Даем UI время вернуться к игре

        print(app.debugDescription) // Проверяем, какой идентификатор у счетчика

        let indexLabel = app.staticTexts["1/10"] // Ищем конкретное значение счетчика

        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Не найден текстовый элемент индекса")
        XCTAssertEqual(indexLabel.label, "1/10", "Счётчик не сбросился на 1/10")
    }
}
