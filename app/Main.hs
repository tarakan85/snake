module Main where

import Config
import Graphics.Gloss
import Graphics.Gloss.Interface.Pure.Game
import Snake

render :: GameState -> Picture
render state = toCorner $ pictures [drawSnake (_snakeBody state), drawFood (_food state)]

onKeyPress :: Event -> GameState -> GameState
onKeyPress (EventKey (SpecialKey KeyRight) Down _ _) gameState =
  gameState {_direction = GoRight, _paused = False}
onKeyPress (EventKey (SpecialKey KeyDown) Down _ _) gameState =
  gameState {_direction = GoDown, _paused = False}
onKeyPress (EventKey (SpecialKey KeyLeft) Down _ _) gameState =
  gameState {_direction = GoLeft, _paused = False}
onKeyPress (EventKey (SpecialKey KeyUp) Down _ _) gameState =
  gameState {_direction = GoUp, _paused = False}
onKeyPress _ gameState = gameState

nextFrame :: Float -> GameState -> GameState
nextFrame dt gameState =
  let snakeBody = _snakeBody gameState
      timePassed = _timePassed gameState
      direction = _direction gameState
      food = _food gameState
      rng = _rng gameState
      paused = _paused gameState
      totTime = dt + timePassed
   in if paused
        then gameState
        else
          if totTime < 1 / speed
            then gameState {_timePassed = totTime}
            else
              let movedSnake = move direction snakeBody
                  trappedOnFood = head movedSnake == food
                  fedSnake = food : snakeBody
                  actualSnake =
                    if trappedOnFood
                      then fedSnake
                      else movedSnake
                  (newFood, rng') = generateFood rng actualSnake
                  actualFood =
                    if trappedOnFood
                      then newFood
                      else food
               in gameState
                    { _snakeBody = actualSnake,
                      _timePassed = 0,
                      _food = actualFood,
                      _rng = rng'
                    }

window :: Display
window = InWindow "Snake" (winWidth, winHeight) (100, 100)

background :: Color
background = white

fps :: Int
fps = 60

main :: IO ()
main = play window background fps initialState render onKeyPress nextFrame
