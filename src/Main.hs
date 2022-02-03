module Main
where

import Board
import Child
import Robot
import Utils
import System.Random

main :: IO ()
main = do

  putStr "\nEscriba la cantidad de turnos para que cambie el ambiente: "
  input0 <- getLine
  let turn = (read input0 :: Int)

  putStr "Escriba la cantidad de filas del ambiente: "
  input1 <- getLine
  let row = (read input1 :: Int)

  putStr "Escriba la cantidad de columnas del ambiente: "
  input2 <- getLine
  let column = (read input2 :: Int)

  putStr "Escriba la cantidad de obstáculos del ambiente: "
  input3 <- getLine
  let obstacles = (read input3 :: Int)

  putStr "Escriba la cantidad de niños del ambiente: "
  input4 <- getLine
  let kids = (read input4 :: Int)

  putStr "Escriba la cantidad de basura del ambiente: "
  input5 <- getLine
  let trash = (read input5 :: Int)

  putStr "Escriba la cantidad de robots del ambiente: "
  input6 <- getLine
  let robots = (read input6 :: Int)

  putStr "Escriba la estrategia seguida por los robots (1 buscan primero niños, 2 buscan primero basura): "
  input7 <- getLine
  let iaRobots = (read input7 :: Int)

  let boardEmpty = board row column

  g <- newStdGen
  let seed = fst (random g)
  let boardWithCorrals = addCorralsBoard seed kids boardEmpty
  let boardWithObstacles = addGenericBoard (seed + 1) "obstacle" obstacles boardWithCorrals
  let boardWithChild = addGenericBoard (seed + 2) "child" kids boardWithObstacles
  let boardWithRobot = addGenericBoard (seed + 3) "robot" robots boardWithChild
  let boardWithTrash = addGenericBoard (seed + 4) "trash" trash boardWithRobot

  let childMoveProbability = 1 / 2
  let trashProbability = 1 / 2
  let countTurn = 1
  let max_loop = 1000

  putStr "\nIMPRIMIR TABLERO INICIAL\n"
  printBoard boardWithTrash

  loop (seed + 5) boardWithTrash childMoveProbability trashProbability countTurn turn iaRobots max_loop

loop :: Int -> Board -> Float -> Float -> Int -> Int -> Int -> Int -> IO ()
loop seed board childMoveProbability trashProbability countTurn turn iaRobots max_loop = do
  let boardWithChildMoved = if mod countTurn turn == 0 then moveChilds seed childMoveProbability trashProbability board else board
  let boardWithRobotMoved = moveRobots boardWithChildMoved iaRobots

  putStr ("TURNO: " ++ show countTurn ++ "\n")
  printBoard boardWithRobotMoved

  let trashAmount =
        length (boardCellTypeEncounter trashConstant boardWithRobotMoved)
          + length (boardCellTypeEncounter robotTrashConstant boardWithRobotMoved)
          + length (boardCellTypeEncounter robotChildTrashConstant boardWithRobotMoved)

  let trasheblesCells =
        trashAmount
          + length (boardCellTypeEncounter robotConstant boardWithRobotMoved)
          + length (boardCellTypeEncounter robotChildConstant boardWithRobotMoved)
          + length (boardCellTypeEncounter childConstant boardWithRobotMoved)
          + length (boardCellTypeEncounter emptyConstant boardWithRobotMoved)

  let cleanCells = trasheblesCells - trashAmount

  let corrals = length (boardCellTypeEncounter corralConstant boardWithRobotMoved)

  if (corrals /= 0 || cleanCells * 100 < trasheblesCells * 60) && countTurn < max_loop
    then loop (seed + 1) boardWithRobotMoved childMoveProbability trashProbability (countTurn + 1) turn iaRobots max_loop
    else
      if countTurn == max_loop
        then putStrLn "MÁXIMA CANTIDAD DE TURNOS ALCANZADA!!!\n"
        else putStr "AMBIENTE LIMPIO!!!\n"