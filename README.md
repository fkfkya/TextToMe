# TextToMe
Anonymous messenger for iOS

**TextToMe** — это анонимный мессенджер для iOS, разработанный на Swift.  
Проект сфокусирован на **конфиденциальности**, **реальном времени** и **удобстве использования**.  
Поддерживает индивидуальные и групповые чаты, шифрование сообщений и мультимедиа.

## Особенности:
- Анонимная авторизация по UUID
- Поддержка текстовых, фото, видео и голосовых сообщений
- Отображение времени, аватаров, статусов "прочитано"
- Групповые чаты и функция вступления по коду
- Firebase Firestore + Storage в качестве backend
- Шифрование сообщений с использованием **CryptoKit**
- Архитектура проекта — **VIPER** + `ModuleBuilder`

## Стэк: 
- `Swift 5`
- `UIKit`
- `VIPER`
- `Firebase Firestore`
- `Firebase Storage`
- `CryptoKit`
- `Keychain`
- `CoreData`

## Архитектура проекта

```plaintext
TextToMe/
├── App/
├── Common/               // Extensions, Enums, Utilities, Protocols
├── Core/                // Crypto, Keychain, FirestoreService, Network
├── Modules/
│   ├── Authorization/
│   ├── ChatList/
│   ├── Chat/
│   ├── CreateChat/
│   └── JoinGroup/
│   └── Settings/
├── Resources/
└── Tests/
