# Task: Add Properties to Gambling Categories

- [x] Analyze current implementation of Models and EditScreen <!-- id: 0 -->
- [x] Update Model Classes <!-- id: 1 -->
    - [x] Update `MahjongResult` <!-- id: 2 -->
    - [x] Update `HorseRacingResult` <!-- id: 3 -->
    - [x] Update `BoatRacingResult` <!-- id: 4 -->
    - [x] Update `KeirinResult` <!-- id: 5 -->
    - [x] Update `AutoRacingResult` <!-- id: 6 -->
    - [x] Update `PachinkoResult` <!-- id: 7 -->
- [x] Update UI (EditScreen) <!-- id: 8 -->
    - [x] Add Form fields for Mahjong <!-- id: 9 -->
    - [x] Add Form fields for Horse Racing <!-- id: 10 -->
    - [x] Add Form fields for Boat Racing <!-- id: 11 -->
    - [x] Add Form fields for Keirin <!-- id: 12 -->
    - [x] Add Form fields for Auto Racing <!-- id: 13 -->
    - [x] Add Form fields for Pachinko <!-- id: 14 -->
- [x] Verify Data Persistence (Firestore) <!-- id: 15 -->
- [x] Final Verification <!-- id: 16 -->

# Task: Refactor Select Properties

- [x] Update Models with Static Lists <!-- id: 17 -->
    - [x] `MahjongResult` (types, umaRates, priceRates, chipRates) <!-- id: 18 -->
    - [x] `PachinkoResult` (types) <!-- id: 19 -->
- [x] Update EditScreen to use Static Lists <!-- id: 20 -->
    - [x] Mahjong forms <!-- id: 21 -->
    - [x] Pachinko forms <!-- id: 22 -->
- [x] Verify Changes <!-- id: 23 -->

# Task: Refine Mahjong Form Logic

- [x] Update `MahjongResult` Model <!-- id: 24 -->
    - [x] Add `umaRates4ma` and `umaRates3ma` static lists <!-- id: 25 -->
- [x] Update `EditScreen` Logic <!-- id: 26 -->
    - [x] Make `_mahjongType` and `_umaRate` nullable <!-- id: 27 -->
    - [x] Implement conditional visibility for Uma field <!-- id: 28 -->
    - [x] Implement conditional options for Uma field based on Type <!-- id: 29 -->
    - [x] Reset/Update `_umaRate` when Type changes <!-- id: 30 -->
- [x] Verify UI Logic <!-- id: 31 -->

# Task: Add Validation

- [x] Add Validators to EditScreen <!-- id: 32 -->
    - [x] Mahjong (priceRate, chipRate, member) <!-- id: 33 -->
    - [x] Racing (betType) <!-- id: 34 -->
    - [x] Pachinko (type, place, machine, member [conditional]) <!-- id: 35 -->
- [x] Verify Validation Logic <!-- id: 36 -->

# Task: Refactor Member Input UI

- [x] Update `EditScreen` State <!-- id: 37 -->
    - [x] Replace `_memberController` with `List<TextEditingController>` <!-- id: 38 -->
    - [x] Initialize controllers from existing data in `initState` <!-- id: 39 -->
    - [x] Implementation disposal of dynamic controllers <!-- id: 40 -->
- [x] Refactor Member Input UI <!-- id: 41 -->
    - [x] Create UI for adding/removing member fields <!-- id: 42 -->
    - [x] Replace single TextFields with dynamic UI in build method <!-- id: 43 -->
- [x] Update Save Logic (`_saveResult`) <!-- id: 44 -->
    - [x] Gather text from all controllers <!-- id: 45 -->
    - [x] Validate non-empty list <!-- id: 46 -->
- [x] Verify Changes <!-- id: 47 -->

# Task: Change Deletion Interaction

- [x] Locate Deletion Logic (ResultCard/HomeScreen) <!-- id: 48 -->
- [x] UI Update <!-- id: 49 -->
    - [x] Remove `onLongPress` <!-- id: 50 -->
    - [x] Add Trash Icon Button to UI (AppBar or Card) <!-- id: 51 -->
    - [x] Connect Delete Action to Button <!-- id: 52 -->
- [x] Verify UI Changes <!-- id: 53 -->
