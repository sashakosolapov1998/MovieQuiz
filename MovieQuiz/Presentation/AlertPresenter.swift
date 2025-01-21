//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Александр Косолапов on 13.01.2025.
//
import UIKit

/// Отвечает за отображение алертов
class AlertPresenter {
    private weak var viewController: UIViewController? // Контроллер для отображения алерта
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
/// Отображает алерт на основе переданной модели
/// - Parameter model: Модель данных для алерта
      func showAlert(with model: AlertModel) {
          let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)

          let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
              model.completion?() // Выполняем замыкание при нажатии кнопки
          }

          alert.addAction(action)
          viewController?.present(alert, animated: true)
      }
    
}
