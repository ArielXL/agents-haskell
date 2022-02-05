module Main
where

import Board
import Child
import Robot
import Utils
import System.Random

main :: IO()
main = do
    g <- newStdGen
    let seed = fst (random g)
    let childMoveProbability = 1 / 2
    let trashProbability = 1 / 2
    let countTurn = 1
    let max_loop = 1000
    
    let boardEmpty1 = board 10 10
    let boardWithCorrals1 = addCorralsBoard seed 4 boardEmpty1
    let boardWithObstacles1 = addGenericBoard (seed + 1) "obstacle" 0 boardWithCorrals1
    let boardWithChild1 = addGenericBoard (seed + 2) "child" 4 boardWithObstacles1
    let boardWithRobot1 = addGenericBoard (seed + 3) "robot" 1 boardWithChild1
    let boardWithTrash1 = addGenericBoard (seed + 4) "trash" 5 boardWithRobot1

    tester (seed + 5) boardWithTrash1 childMoveProbability trashProbability countTurn 1 1 max_loop (10 * 10)
    -- tester (seed + 6) boardWithTrash1 childMoveProbability trashProbability countTurn 1 2 max_loop (10 * 10)
    -- tester (seed + 7) boardWithTrash1 childMoveProbability trashProbability countTurn 3 1 max_loop (10 * 10)
    -- tester (seed + 8) boardWithTrash1 childMoveProbability trashProbability countTurn 3 2 max_loop (10 * 10)

    let boardEmpty2 = board 10 10
    let boardWithCorrals2 = addCorralsBoard (seed + 10) 6 boardEmpty2
    let boardWithObstacles2 = addGenericBoard (seed + 11) "obstacle" 5 boardWithCorrals2
    let boardWithChild2 = addGenericBoard (seed + 12) "child" 6 boardWithObstacles2
    let boardWithRobot2 = addGenericBoard (seed + 13) "robot" 3 boardWithChild2
    let boardWithTrash2 = addGenericBoard (seed + 14) "trash" 10 boardWithRobot2

    -- tester (seed + 15) boardWithTrash2 childMoveProbability trashProbability countTurn 2 1 max_loop (10 * 10)
    -- tester (seed + 16) boardWithTrash2 childMoveProbability trashProbability countTurn 2 2 max_loop (10 * 10)
    -- tester (seed + 17) boardWithTrash2 childMoveProbability trashProbability countTurn 4 1 max_loop (10 * 10)
    -- tester (seed + 18) boardWithTrash2 childMoveProbability trashProbability countTurn 4 2 max_loop (10 * 10)

    let boardEmpty3 = board 10 10
    let boardWithCorrals3 = addCorralsBoard (seed + 20) 8 boardEmpty3
    let boardWithObstacles3 = addGenericBoard (seed + 21) "obstacle" 10 boardWithCorrals3
    let boardWithChild3 = addGenericBoard (seed + 22) "child" 8 boardWithObstacles3
    let boardWithRobot3 = addGenericBoard (seed + 23) "robot" 5 boardWithChild3
    let boardWithTrash3 = addGenericBoard (seed + 24) "trash" 15 boardWithRobot3

    -- tester (seed + 25) boardWithTrash3 childMoveProbability trashProbability countTurn 3 1 max_loop (10 * 10)
    tester (seed + 26) boardWithTrash3 childMoveProbability trashProbability countTurn 3 2 max_loop (10 * 10)

tester :: Int -> Board -> Float -> Float -> Int -> Int -> Int -> Int -> Int -> IO ()
tester seed board childMoveProbability trashProbability countTurn turn iaRobots max_loop total = do

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
    putStrLn ("Total de casillas sucias: " ++ show trashAmount)
    putStrLn ("Total de casillas posibles a ensuciar: " ++ show trasheblesCells)
    putStrLn ("Total de casillas limpias: " ++ show cleanCells ++ "\n")
    let a = div (trashAmount * 100) trasheblesCells
    putStrLn ("Por ciento de suciedad: " ++ show a ++ " %\n")
    let corrals = length (boardCellTypeEncounter corralConstant boardWithRobotMoved)

    if (corrals /= 0 || trashAmount * 100 >= 60 * total) && countTurn < max_loop
        then tester (seed + 1) boardWithRobotMoved childMoveProbability trashProbability (countTurn + 1) turn iaRobots max_loop total
        else
        if countTurn == max_loop
            then putStrLn "MÁXIMA CANTIDAD DE TURNOS ALCANZADA!!!\n"
            else putStrLn "AMBIENTE LIMPIO!!!\n"