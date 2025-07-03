% Purpose: Play the major parts of Cribbage
%
% Game play begins with the dealer dealing each player 6 or 5 cards depending
% on the number of players in a game. Each player then chooses 1 or 2 cards
% to discard, keeping 4 and putting the discarded cards in the crib. This is
% done by maximixing the value of a player's hand. For this phase, the start
% card is usually considered as part of each player's hand, so each player
% establishes the value of a 5 card hand. Points are scored for certain
% combinations of cards according to the rules of Cribbage.

%% card_to_num(+Rank, -Number) is det
%
%  Converts the card's Rank to a corresponding Number if they
%  are a face card, otherwise, it is just their original rank.
card_to_num(Rank, Number) :-
    (Rank = ace -> Number = 1
    ; Rank = jack -> Number = 11
    ; Rank = queen -> Number = 12
    ; Rank = king -> Number = 13
    ; Number = Rank).

%% card_to_val(+Rank, -Value) is det
%
%  Converts the card's Rank to a corresponding numeric Value if 
%  they are a face card, otherwise, it is just their original rank.
card_to_val(Rank, Value) :-
    (Rank = ace -> Value = 1
    ; Rank = jack -> Value = 10
    ; Rank = queen -> Value = 10
    ; Rank = king -> Value = 10
    ; Value = Rank).

%% subset(+List, -Subset) is det
%
%  Holds when Subset is a possible combination from List, in the same
%  order they appear in List. This should work whenever List is a proper list.
subset([], []).
subset([X | Xs], [X | Subset]) :-
    subset(Xs, Subset).
subset([_ | Xs], Subset) :-
    subset(Xs, Subset).

%% fifteens(+List, -Score) is det
%
%  Finds each distinct combination of List that sums to 15.
%  Then calculates the number of distinct combinations and
%  calculates the score for each.
fifteens(List, Score) :-
    findall(Subset, (subset(List, Subset), sum_list(Subset, 15)), Subsets),
    length(Subsets, Length),
    % 2 points are scored for each distinct combination.
    Score is Length * 2.

%% count(+List, +Element, -Count) is det
%
%  Holds when Count is the number of occurences of Element in List.
count(List, Element, Count) :-
    include(=(Element), List, List2),
    length(List2, Count).

%% pairs(+Uniq_List, +List, Score) is det
%
%  First counts the number of occurences in List of each unique element 
%  in Uniq_List. Then assigns the number of points for each number of 
%  occurences. Finally, sums all the total points together in Score.
pairs([], _, 0).
pairs([X | Xs], List, Score) :-
    count(List, X, Count),
    % Assigns the points for each number of occurences.z
    (Count = 2 -> Score1 = 2
    ; Count = 3 -> Score1 = 6
    ; Count = 4 -> Score1 = 12
    ; Score1 = 0),
    pairs(Xs, List, Score2),
    Score is Score1 + Score2.

%% consecutive(+List) is nondet
%
%  Holds true when the elements of List are consecutive.
%  Only works when List is sorted.
consecutive([_]).
consecutive([X, Y | Tail]) :-
    Y is X + 1,
    consecutive([Y | Tail]).

%% find_max(+List, -Max) is det
%
%  True if Max is the largest number in List.
%  However, does not fail if List is empty, only returns 0.
find_max([], 0).
find_max(List, Max) :-
    max_list(List, Max).

%% runs(+List, -Score) is det
%
%  Calculates the Score of the number of runs in a List.
runs(List, Score) :-
    % Finds all possible subsets with 3 or more consecutive cards.
    findall(Subset, (subset(List, Subset), 
                    length(Subset, Length), 
                    Length >= 3, 
                    consecutive(Subset))
            , Subsets),
    % Find the maximum number of run possible.
    maplist(length, Subsets, Num_Subsets),
    find_max(Num_Subsets, Max),
    % Filter out only the larger number of runs.
    findall(X, (member(X, Subsets), length(X, Max)), Runs),
    % Deals with the case where a number can be used twice in a run.
    length(Runs, Num_Runs),
    Score is Num_Runs * Max.

%% flushes(+List, -Score) is det
%
%  Calculates the Score of whether the cards in the hand 
%  List are the same suit. Fails if List does not have 5
%  elements.
flushes([S1, S2, S3, S4, SCS], Score) :-
    ( S1 = S2, S2 = S3, S3 = S4 -> 
        ( SCS = S4 -> 
            Score = 5
        ; Score = 4)
    ; Score = 0).

%% one_for_his_nob(+List, +Suit, -Score) is det
%
%  Calculates the Score when the player's hand List contains
%  the jack of the same suit. List must be in the template
%  Rank-Suit.
one_for_his_nob(List, Suit, Score) :-
    (member(jack-Suit, List) -> Score = 1
    ; Score = 0).

%% hand_value(+Hand, +Startcard, -Value) is semidet
%
%  Calculates the total cribbage point Value of a player's Hand 
%  given the Startcard. Hand must be represented as a proper
%  list of 4 card terms in the form card(Rank, Suit), where 
%  Rank is either an integer between 2 and 10, or one of ace,
%  jack, queen, or king, and Suit is one of clubs, diamonds,
%  hearts, or spades. Startcard is a single card term.
hand_value([card(R1, S1), card(R2, S2), card(R3, S3), card(R4, S4)], 
           card(SCR, SCS), Value) :-
    % Convert cards to suitable formats
    maplist(card_to_num, [R1, R2, R3, R4, SCR], Numbers),
    maplist(card_to_val, [R1, R2, R3, R4, SCR], Values),
    Suits = [S1, S2, S3, S4, SCS],
    Key_Value = [R1-S1, R2-S2, R3-S3, R4-S4],
    % Sort the cards
    sort(Numbers, Sort_Uniq),
    msort(Numbers, Sort_Dup),
    % Perform each rules on the hand
    fifteens(Values, Fifteens_Score),
    pairs(Sort_Uniq, Sort_Dup, Pairs_Score),
    runs(Sort_Dup, Runs_Score), % revise this
    flushes(Suits, Flushes_Score),
    one_for_his_nob(Key_Value, SCS, Nob_Score),
    % Sums the score of each rules
    sum_list([Fifteens_Score, Pairs_Score, Runs_Score, Flushes_Score,Nob_Score], 
             Value).

%% remaining_cards(+Cards, -Remains) is det
%
%  Holds when Remains is the list of elements inside All,
%  but not inside Cards.
remaining_cards(Cards, Remains) :-
    numlist(2, 10, Num),
    Ranks = [ace, jack, queen, king | Num],
    Suits = [hearts, diamonds, clubs, spades],
    setof(card(Rank, Suit), (member(Rank, Ranks), member(Suit, Suits)), All),
    subtract(All, Cards, Remains).

%% find_sum(+Key_Values, -Sums) is semidet
%
%  Holds when each corresponding element of Sums is the summation 
%  of values grouped by their keys in Key_Values, where Key_Values is a 
%  proper list.
find_sum(Key_Values, Sums) :-
    % Uses a helper predicate to make it tail recursive.
    find_sum_tail_rec(Key_Values, 0, Sums).

%% find_sum_tail_rec(+Key_Values, +Acc, -Sums) is semidet
%
%  A helper predicate to make find_sum/2 tail recursive. 
%  Works when Key_Valuesis a list of key-value pairs. 
%  Acc is the accumulator used for the summation.
%  Sums is the list of aggregated sums of each key.
find_sum_tail_rec([_-Value], Acc, [Sum]) :- 
    Sum is Acc + Value.
% If the keys are the same, just continue summing the values.
find_sum_tail_rec([Key-Value1, Key-Value2 | Tail], Acc, SumList) :-
    NewAcc is Acc + Value1,
    find_sum_tail_rec([Key-Value2 | Tail], NewAcc, SumList).
% If the keys are different, start with a new 0 accumulator for the next key.
find_sum_tail_rec([Key1-Value1, Key2-Value2 | Tail], Acc, [Sum | SumList]) :-
    Key1 \= Key2,
    Sum is Acc + Value1,
    find_sum_tail_rec([Key2-Value2 | Tail], 0, SumList).

%% correspond(?Sums, ?Combs, ?Max, ?Comb) is semidet
%
%  Holds when Comb is the Sum's corresponding element Max in Combs.
correspond([Max | _], [Comb | _], Max, Comb).
correspond([_HeadSum | TailSum], [_CombHead | CombTail], Max, Comb) :-
    correspond(TailSum, CombTail, Max, Comb). 

%% select_hand(+Cards, -Hand, -Cribcards) is semidet
%
%  Selects the list Hand of 4 cards to be kept from 5 or 6 cards 
%  in Cards dealt to a player at the start of the hand. The cards 
%  to be kept in the Hand are chosen to maximize the expected
%  value of the hand over all the other start cards.
select_hand(Cards, Hand, Cribcards) :-
    % Finds the remaining cards apart from Hand.
    remaining_cards(Cards, Remains),
    % Finds all the possible hands of length 4 from the given Cards.
    findall(Subset, (subset(Cards, Subset), length(Subset, 4)), Subsets),
    % For each possible hand, enumerate through all the possible start cards
    % and calculate all of the hand values.
    findall(Key-Value, (member(Key, Subsets), 
                   member(Y, Remains), 
                   hand_value(Key, Y, Value)), 
            Key_Values),
    % Aggregate the hand values over each possible hands. Since the cards
    % are compared with one another, it was unnecessary to obtain the
    % average as comparison of their sums would be sufficient. The result
    % is just values instead of key-value pairs to make it easier for the
    % find_max/2 predicate to search for the highest hand value.
    find_sum(Key_Values, Sums),
    % Finds the hand with the highest value.
    find_max(Sums, Max),
    % Find the 4-card hand corresponding to the highest value. 
    % Works because the elements of the Sums would correspond in the same
    % order as the elements of Subsets.
    correspond(Sums, Subsets, Max, Hand),
    % Obtain the Cribcards after discarding the unwanted cards from Card.
    subtract(Cards, Hand, Cribcards).