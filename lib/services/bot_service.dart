import 'package:flutter/material.dart';

class BotCommand {
  final String command;
  final String description;
  final String response;

  BotCommand({required this.command, required this.description, required this.response});
}

class Bot {
  final String id;
  final String name;
  final String username;
  final String description;
  final Color avatarColor;
  final List<BotCommand> commands;

  Bot({
    required this.id,
    required this.name,
    required this.username,
    required this.description,
    required this.avatarColor,
    required this.commands,
  });
}

final List<Bot> defaultBots = [
  Bot(
    id: 'helper_bot',
    name: 'Helper Bot',
    username: 'helper',
    description: 'Your friendly assistant. Ask me anything about using the app!',
    avatarColor: Colors.blue,
    commands: [
      BotCommand(command: '/start', description: 'Start the bot', response: 'Welcome to Helper Bot!'),
      BotCommand(command: '/about', description: 'About this bot', response: 'Helper Bot is a built-in assistant.'),
    ],
  ),
  Bot(
    id: 'reminder_bot',
    name: 'Reminder Bot',
    username: 'reminder',
    description: 'Set reminders and never forget important tasks.',
    avatarColor: Colors.green,
    commands: [
      BotCommand(command: '/start', description: 'Start the bot', response: 'Welcome to Reminder Bot!'),
      BotCommand(command: '/remind', description: 'Set a reminder', response: 'Use /remind [time] [message]'),
    ],
  ),
  Bot(
    id: 'quiz_bot',
    name: 'Quiz Bot',
    username: 'quiz',
    description: 'Test your knowledge with fun trivia questions!',
    avatarColor: Colors.pink,
    commands: [
      BotCommand(command: '/start', description: 'Start the bot', response: 'Welcome to Quiz Bot!'),
      BotCommand(command: '/play', description: 'Start a quiz', response: 'What is the capital of France?'),
    ],
  ),
  Bot(
    id: 'news_bot',
    name: 'News Bot',
    username: 'news',
    description: 'Stay updated with the latest headlines and trending topics.',
    avatarColor: Colors.orange,
    commands: [
      BotCommand(command: '/start', description: 'Start the bot', response: 'Welcome to News Bot!'),
      BotCommand(command: '/latest', description: 'Get latest news', response: 'Here are today\'s top stories...'),
    ],
  ),
];
