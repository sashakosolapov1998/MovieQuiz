//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Александр Косолапов on 18.01.2025.
//
import Foundation
final class StatisticService {
    // Приватное свойство для хранения UserDefaults
    private let storage: UserDefaults = .standard
    // Приватный класс для ключей
    private enum Keys: String {
        case correctAnswers
        case totalQuestions
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
    }
}
    extension StatisticService: StatisticServiceProtocol {
        var gamesCount: Int {
            get {
                // читаем значение из UserDefaults, и используем storage вместо UserDefaults
                storage.integer(forKey: Keys.gamesCount.rawValue)
            }
            set {
                // сохраняем значение newValue в UserDefaults
                storage.set(newValue, forKey: Keys.gamesCount.rawValue)
            }
        }
        
        var bestGame: GameResult {
            get {
                //читаем количество правильных ответов
                let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
                //читаем общее количество вопросов
                let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
                // читаем дату, если ее нет, то используем текущую
                let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
                // возвращаем экземпляр GameResult
                return GameResult(correct: correct, total: total, date: date)
            }
            set {
                // сохраняем количество правильных ответов
                storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
                //сохраняем общее количество вопросов
                storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
                // сохраняем дату квиза
                storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
            }
        }
        // Добавить приватное свойство для хранения количества правильных ответов
        private var correctAnswers: Int {
            get {
                return storage.integer(forKey:Keys.correctAnswers.rawValue)
            }
            set {
                storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
            }
        }
        //
        var totalAccuracy: Double {
            let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
            guard totalQuestions > 0 else {return 0.0}
            return (Double(correctAnswers) / Double(totalQuestions)) * 100
        }
        
        func store(correct count: Int, total amount: Int) {
            // Обновляем общее количество правильных ответов
            correctAnswers += count
            
            // Обновляем общее количество вопросов
            let currentTotal = storage.integer(forKey: Keys.totalQuestions.rawValue)
            storage.set(currentTotal + amount, forKey: Keys.totalQuestions.rawValue)
           
            // Увеличиваем количество сыгранных игр
            gamesCount += 1
            
            // Проверяем, является ли текущий результат лучшим
            if count > bestGame.correct {
                let newBestGame = GameResult(correct: count, total: amount, date: Date())
                bestGame = newBestGame
            }
        }
        
    }

