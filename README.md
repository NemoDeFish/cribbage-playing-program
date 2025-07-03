# 🃏 Cribbage-Playing Program in Prolog

A logic-based cribbage hand evaluator and strategy engine implemented in Prolog. This project focuses on scoring hands during the *show* phase of Cribbage and selecting optimal hands based on expected value.

## 📚 About Cribbage

Cribbage is a classic card game originating in 17th-century England, played by 2, 3, or 4 players. The goal is to reach 121 points first, scoring points through card combinations in specific phases of the game.

This project focuses on the *show* phase of the game, where players evaluate their hands (plus a start card) to score points. Points are determined based on various card combinations, such as pairs, runs, flushes, and totals of 15. For a more complete overview of cribbage rules, refer to external resources, but the rules provided here are sufficient for this project.

## ✨ Features

* Full implementation of cribbage scoring rules:

  - **15s**: 2 points for each combination of cards that total 15.
  - **Pairs**: 2 points for each pair. Three-of-a-kind scores 6 points, and four-of-a-kind scores 12 points.
  - **Runs**: 1 point per card in a sequence of 3 or more consecutive ranks (suit does not matter).
  - **Flushes**: 4 points for a hand of the same suit. An additional 1 point if the start card matches the suit.
  - **"One for his nob"**: 1 point if the hand contains the jack of the same suit as the start card.
* Logic to choose the best possible hand out of 5 or 6 dealt cards
* Clean, declarative implementation in Prolog

## 🧠 Core Predicates

### `hand_value/3`

```prolog
hand_value(Hand, Startcard, Value).
```

* Calculates the total point value of a Cribbage hand and start card.
* `Hand`: List of 4 cards (`card(Rank, Suit)`).
* `Startcard`: A single card.
* `Value`: Total score (integer).

### `select_hand/3`

```prolog
select_hand(Cards, Hand, Cribcards).
```

* Chooses the best 4 cards from 5 or 6 dealt cards to maximize the average expected value.
* `Cards`: Dealt cards (list of 5 or 6).
* `Hand`: Selected 4-card hand.
* `Cribcards`: Remaining cards sent to the crib.

## 🔢 Example Scoring

| Hand              | Start Card | Points |
| ----------------- | ---------- | ------ |
| \[7♣, Q♥, 2♣, J♣] | 9♥         | 0      |
| \[A♠, 3♥, K♥, 7♥] | K♠         | 2      |
| \[A♠, 3♥, K♥, 7♥] | 2♦         | 5      |
| \[6♣, 7♣, 8♣, 9♣] | 8♠         | 20     |
| \[7♥, 9♠, 8♣, 7♣] | 8♥         | 24     |
| \[5♥, 5♠, 5♣, J♦] | 5♦         | 29     |

The dealer also scores points from the crib (a separate hand formed from player discards).

## 📦 Project Structure

```
.
├── cribbage.pl          # Cribbage logic
├── README.md            # This file
```

## 🚀 Getting Started

### Requirements

* [SWI-Prolog](https://www.swi-prolog.org/) or another ISO-compatible Prolog interpreter

### Running the Program

1. Launch your Prolog interpreter:

   ```bash
   swipl
   ```
2. Load the cribbage program:

   ```prolog
   ?- [search/program].
   ```
3. Test a hand:

   ```prolog
   ?- hand_value([card(7, clubs), card(queen, hearts), card(2, clubs), card(jack, clubs)], card(9, hearts), Value).
   ```

## 📌 Notes

* Ranks: `ace`, `2`–`10`, `jack`, `queen`, `king`
* Suits: `clubs`, `diamonds`, `hearts`, `spades`
* Card terms follow the format: `card(Rank, Suit)`