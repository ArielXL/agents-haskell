module Board
  ( 
    Board,
    Position,
    CellType,
    PositionBoardCell,
    board,
    addCorralsBoard,
    addGenericBoard,
    filterByTypeCell,
    get4AdyacentCells,
    boardCellTypeEncounter,
    getFirstCellLine,
    get9Cells,
    robotConstant,
    childConstant,
    trashConstant,
    emptyConstant,
    corralConstant,
    obstacleConstant,
    robotCorralConstant,
    robotChildConstant,
    robotChildCorralConstant,
    robotTrashConstant,
    robotChildTrashConstant,
    childCorralConstant,
  )
where

import Utils
import Random

robotConstant = "robot"

childConstant = "child"

trashConstant = "trash"

emptyConstant = "empty"

corralConstant = "corral"

obstacleConstant = "obstacle"

robotCorralConstant = "robot-corral"

robotChildConstant = "robot-child"

robotChildCorralConstant = "robot-child-corral"

robotTrashConstant = "robot-trash"

robotChildTrashConstant = "robot-child-trash"

childCorralConstant = "child-corral"

type CellType = String

type Pick = Bool

type Drop = Bool

type Position = (Int, Int)

type BoardCell = (CellType, Pick, Drop)

type PositionBoardCell = (Position, BoardCell)

type Board = [[PositionBoardCell]]

board :: Int -> Int -> Board
board rEnd cEnd
  | rEnd == 0 || cEnd == 0 = []
  | otherwise              = boardFormer 0 rEnd cEnd

boardFormer :: Int -> Int -> Int -> Board
boardFormer r rEnd cEnd
  | r == rEnd = []
  | otherwise = boardRow r 0 cEnd : boardFormer (r + 1) rEnd cEnd

boardRow :: Int -> Int -> Int -> [PositionBoardCell]
boardRow r c cEnd
  | c == cEnd = []
  | otherwise = ((r, c), ("empty", False, False)) : boardRow r (c + 1) cEnd

boardCellTypeEncounter :: CellType -> Board -> [PositionBoardCell]
boardCellTypeEncounter cellType board = boardCellTypeEncounterRow cellType board 0 (length board)

boardCellTypeEncounterRow :: CellType -> Board -> Int -> Int -> [PositionBoardCell]
boardCellTypeEncounterRow cellType board r rEnd
  | r == rEnd = []
  | otherwise = boardCellTypeEncounterColmn cellType board r 0 (length (board !! r)) ++ boardCellTypeEncounterRow cellType board (r + 1) rEnd

boardCellTypeEncounterColmn :: CellType -> Board -> Int -> Int -> Int -> [PositionBoardCell]
boardCellTypeEncounterColmn cellType board r c cEnd
  | c == cEnd                                                = []
  | getCellType (getBoardCell (board !! r !! c)) == cellType = (board !! r !! c) : boardCellTypeEncounterColmn cellType board r (c + 1) cEnd
  | otherwise                                                = boardCellTypeEncounterColmn cellType board r (c + 1) cEnd

get4AdyacentCells :: Position -> [[(Position, a)]] -> [(Position, a)]
get4AdyacentCells (r, c) board = result
  where
    rows = length board
    columns = length (head board)
    up
      | r == 0    = []
      | otherwise = [board !! (r - 1) !! c]
    down
      | r == (rows - 1) = []
      | otherwise       = [board !! (r + 1) !! c]
    left
      | c == 0    = []
      | otherwise = [board !! r !! (c - 1)]
    right
      | c == (columns - 1) = []
      | otherwise          = [board !! r !! (c + 1)]
    result = up ++ down ++ left ++ right

get4CrossCells :: Position -> Board -> [PositionBoardCell]
get4CrossCells (r, c) board = result
  where
    rows = length board
    columns = length (head board)
    upLeft
      | r == 0 || c == 0 = []
      | otherwise        = [board !! (r - 1) !! (c - 1)]
    downLeft
      | r == (rows - 1) || c == 0 = []
      | otherwise                 = [board !! (r + 1) !! (c - 1)]
    upRight
      | r == 0 || c == (columns - 1) = []
      | otherwise                    = [board !! (r - 1) !! (c + 1)]
    downRight
      | r == (rows - 1) || c == (columns - 1) = []
      | otherwise                             = [board !! (r + 1) !! (c + 1)]
    result = upLeft ++ downLeft ++ upRight ++ downRight

get8Cells :: Position -> Board -> [PositionBoardCell]
get8Cells p board = get4AdyacentCells p board ++ get4CrossCells p board

get9Cells :: Position -> Board -> [PositionBoardCell]
get9Cells p board = get8Cells p board ++ [board !! getRow p !! getColumn p]

getFirstCellLine :: Position -> Position -> Position -> CellType -> CellType -> Board -> PositionBoardCell
getFirstCellLine positionIni position direction cellTypeObjetive cellTypeObstacle board =
  let rows = length board
      columns = length (head board)
      result
        | getRow position < 0 || getRow position >= rows || getColumn position < 0 || getColumn position >= columns = board !! getRow positionIni !! getColumn positionIni
        | getCellType (getBoardCell (board !! getRow position !! getColumn position)) == cellTypeObjetive = board !! getRow position !! getColumn position
        | getCellType (getBoardCell (board !! getRow position !! getColumn position)) == cellTypeObstacle = getFirstCellLine positionIni (getRow position + getRow direction, getColumn position + getColumn direction) direction cellTypeObjetive cellTypeObstacle board
        | otherwise = board !! getRow positionIni !! getColumn positionIni
   in result

filterByTypeCell :: CellType -> [PositionBoardCell] -> [PositionBoardCell]
filterByTypeCell _ [] = []
filterByTypeCell cellType ((p, x) : xs)
  | getCellType x == cellType = (p, x) : filterByTypeCell cellType xs
  | otherwise                 = filterByTypeCell cellType xs

addCorralsBoard :: Int -> Int -> Board -> Board
addCorralsBoard seed amount board
  | amount == 0 = board
  | null corralsAlready =
    let emptyCells = boardCellTypeEncounter "empty" board
        randomCell = randomRange 0 (length emptyCells - 1) (runRandom rand seed)
        ((rR, rC), _) = emptyCells !! randomCell
        boardR = replace board rR (replace (board !! rR) rC ((rR, rC), ("corral", False, False)))
     in addCorralsBoard rR (amount - 1) boardR
  | otherwise =
    let corralCells = boardCellTypeEncounter "corral" board
        corralWithAdyacents = map (\((r, c), x) -> (((r, c), x), get4AdyacentCells (r, c) board)) corralCells
        corralWithEmptyAdyacents = map (\(x, l) -> (x, filterByTypeCell "empty" l)) corralWithAdyacents
        corralWithEmptyAdyacentsNotNull = filter (\(_, l) -> not (null l)) corralWithEmptyAdyacents

        randomCorral = randomRange 0 (length corralWithEmptyAdyacentsNotNull - 1) (runRandom rand seed)
        (((rR, rC), _), l) = corralWithEmptyAdyacentsNotNull !! randomCorral

        randomEmpty = randomRange 0 (length l - 1) (runRandom rand rR)
        ((rER, rEC), _) = l !! randomEmpty

        boardR = replace board rER (replace (board !! rER) rEC ((rER, rEC), ("corral", False, False)))
     in addCorralsBoard rER (amount - 1) boardR
  where
    corralsAlready = boardCellTypeEncounter "corral" board

addGenericBoard :: Int -> CellType -> Int -> Board -> Board
addGenericBoard seed cellType amount board
  | amount == 0 = board
  | otherwise =
    let emptyCells = boardCellTypeEncounter "empty" board
        randomCell = randomRange 0 (length emptyCells - 1) (runRandom rand seed)
        ((rR, rC), _) = emptyCells !! randomCell
        boardR = replace board rR (replace (board !! rR) rC ((rR, rC), (cellType, False, False)))
     in addGenericBoard rR cellType (amount - 1) boardR