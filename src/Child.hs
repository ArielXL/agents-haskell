module Child
  (
    moveChilds
  )
where

import Board
import Utils
import Random

moveChilds :: Int -> Float -> Float -> Board -> Board
moveChilds seed moveProbability trashProbability board = 
  moveChildsList seed moveProbability trashProbability (boardCellTypeEncounter "child" board) board

moveChildsList :: Int -> Float -> Float -> [PositionBoardCell] -> Board -> Board
moveChildsList _ _ _ [] board = board
moveChildsList seed moveProbability trashProbability ((p, cell) : xs) board =
  let randomChoice = randomRange 0 100 (runRandom rand seed)
      boardR
        | randomChoice <= round (moveProbability * 100) =
          let moveChoices = get4AdyacentCells p board
              randomMoveIndex = randomRange 0 (length moveChoices) (runRandom rand randomChoice)
              cellDestiny = moveChoices !! randomMoveIndex
              boardRR
                | getCellType (getBoardCell cellDestiny) == "empty" || getCellType (getBoardCell cellDestiny) == "obstacle" =
                  let direction = (getRow (getPosition cellDestiny) - getRow p, getColumn (getPosition cellDestiny) - getColumn p)
                      destinySwap = getFirstCellLine p (getRow p + getRow direction, getColumn p + getColumn direction) direction "empty" "obstacle" board
                      boardAfterMove = swapPosition p (getPosition cellDestiny) (swapPosition (getPosition cellDestiny) (getPosition destinySwap) board)
                   in generateTrash (seed + 1) trashProbability p boardAfterMove
                | otherwise = board
           in boardRR
        | otherwise = board
   in moveChildsList randomChoice moveProbability trashProbability xs boardR

generateTrash :: Int -> Float -> Position -> Board -> Board
generateTrash seed trashProbability p board = generateTrashList seed trashProbability (map getPosition (get9Cells p board)) board

generateTrashList :: Int -> Float -> [Position] -> Board -> Board
generateTrashList _ _ [] board = board
generateTrashList seed trashProbability ((r, c) : xs) board =
  let adyacents = get9Cells (r, c) board
      boardR
        | length adyacents == 9 =
          let amountChild = length (filter (\(p, c) -> getCellType c == "child") adyacents)
              amountTrash = length (filter (\(p, c) -> getCellType c == "trash") adyacents)
              trashToGenerate
                | amountChild == 1 && amountTrash < 1 = 1 - amountTrash
                | amountChild == 2 && amountTrash < 3 = 3 - amountTrash
                | amountChild >= 3 && amountTrash < 6 = 6 - amountTrash
                | otherwise = 0
              emptyCells = filter (\(p, c) -> getCellType c == "empty") adyacents
           in trashCell seed trashProbability trashToGenerate emptyCells board
        | otherwise = board
   in generateTrashList (seed + 1) trashProbability xs boardR

trashCell :: Int -> Float -> Int -> [PositionBoardCell] -> Board -> Board
trashCell _ _ 0 _ board = board
trashCell _ _ _ [] board = board
trashCell seed trashProbability trashToGenerate ((p, c) : xs) board =
  let randomChoice = randomRange 0 100 (runRandom rand seed)
      boardR
        | randomChoice <= round (trashProbability * 100) =
          trashCell randomChoice trashProbability (trashToGenerate - 1) xs (replaceInBoard (p, ("trash", False, False)) board)
        | otherwise = trashCell randomChoice trashProbability trashToGenerate xs board
   in boardR