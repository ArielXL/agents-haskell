module Random
  (
    runRandom,
    rand,
    randomRange
  )
where

import System.Random
import Control.Monad.State (State, evalState, get, put)

type R a = State StdGen a

runRandom :: R a -> Int -> a
runRandom action seed = evalState action $ mkStdGen seed

rand :: R Int
rand = do
  gen <- get
  let (r, gen') = random gen
  put gen'
  return r

randomRange :: Int -> Int -> Int -> Int
randomRange low up n
  | low == up = low
  | a > 0     = low + a
  | otherwise = low + (-1 * a)
  where
    a = mod n (up - low)