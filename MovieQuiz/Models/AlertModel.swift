//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Александр Косолапов on 13.01.2025.
//

import Foundation

/// Модель данных для отображения алерта
struct AlertModel {
    let title: String       // Заголовок алерта
    let message: String     // Сообщение
    let buttonText: String  // Текст кнопки
    let completion: (() -> Void)? // Действие при нажатии кнопки
}
