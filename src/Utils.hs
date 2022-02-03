module Utils
  (
    replace,
    replaceInBoard,
    replaceInBoardList,
    swapPosition,
    getPosition,
    getBoardCell,
    getCellType,
    getDrop,
    getRow,
    getColumn,
    printBoard,
    isMember
  )
where

replace :: [a] -> Int -> a -> [a]
replace list index element = let (first, x : xs) = splitAt index list in first ++ (element : xs)

replaceInBoard :: ((Int, Int), a) -> [[((Int, Int), a)]] -> [[((Int, Int), a)]]
replaceInBoard ((r, c), x) board = replace board r (replace (board !! r) c ((r, c), x))

replaceInBoardList :: [((Int, Int), a)] -> [[((Int, Int), a)]] -> [[((Int, Int), a)]]
replaceInBoardList [] board = board
replaceInBoardList (((r, c), x) : xs) board = replaceInBoardList xs (replace board r (replace (board !! r) c ((r, c), x)))

swapPosition :: (Int, Int) -> (Int, Int) -> [[((Int, Int), (String, Bool, Bool))]] -> [[((Int, Int), (String, Bool, Bool))]]
swapPosition (originR, originC) (destinyR, destinyC) board =
  replaceInBoard ((originR, originC), y) (replaceInBoard ((destinyR, destinyC), x) board)
  where
    x = getBoardCell (board !! originR !! originC)
    y = getBoardCell (board !! destinyR !! destinyC)

getPosition :: (p, c) -> p
getPosition (p, c) = p

getBoardCell :: (p, c) -> c
getBoardCell (p, c) = c

getCellType :: (String, Bool, Bool) -> String
getCellType (c, p, d) = c

getDrop :: (String, Bool, Bool) -> Bool
getDrop (_, _, d) = d

getRow :: (Int, Int) -> Int
getRow (r, c) = r

getColumn :: (Int, Int) -> Int
getColumn (r, c) = c

printBoard :: [[((Int, Int), (String, Bool, Bool))]] -> IO ()
printBoard [] = putStr "\n"
printBoard (x : xs) = do
  printColumn x
  printBoard xs

printColumn :: [((Int, Int), (String, Bool, Bool))] -> IO ()
printColumn [] = putStr "\n"
printColumn ((_, (c, _, _)) : xs) = do
  putStr
    ( let p
            | c == "robot"              = "[  R  ]"
            | c == "child"              = "[  C  ]"
            | c == "trash"              = "[  T  ]"
            | c == "corral"             = "[  H  ]"
            | c == "empty"              = "[     ]"
            | c == "obstacle"           = "[  X  ]"
            | c == "robot-trash"        = "[ RT  ]"
            | c == "robot-child"        = "[ RC  ]"
            | c == "robot-corral"       = "[ RH  ]"
            | c == "child-corral"       = "[ CH  ]"
            | c == "robot-child-corral" = "[ RCH ]"
            | c == "robot-child-trash"  = "[ RCT ]"
            | otherwise                 = ""
       in p
    )
  printColumn xs

isMember :: Eq t => t -> [t] -> Bool
isMember n [] = False
isMember n (x : xs)
  | n == x    = True
  | otherwise = isMember n xs