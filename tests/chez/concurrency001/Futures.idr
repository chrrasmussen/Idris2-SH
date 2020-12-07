module Futures

import Data.List
import Data.So
import System
import System.Future
import System.Info

constant : IO ()
constant = do
  let a = await $ fork "String"
  putStrLn a

partial
futureHelloWorld : (Int, String) -> IO (Future Unit)
futureHelloWorld (us, n) with (choose (us >= 0))
  futureHelloWorld (us, n) | Left p = forkIO $ do
    usleep us
    putStrLn $ "Hello " ++ n ++ "!"

partial
simpleIO : IO (List Unit)
simpleIO = do
  futures <- sequence $ futureHelloWorld <$> [(30000, "World"), (10000, "Bar"), (0, "Foo"), (20000, "Idris")]
  let awaited = await <$> futures
  pure awaited

nonbind : IO (Future ())
nonbind = forkIO $ putStrLn "This shouldn't print"

erasureAndNonbindTest : IO ()
erasureAndNonbindTest = do
  _ <- forkIO $ do
    putStrLn "This line is printed"
  notUsed <- forkIO $ do
    usleep 10000
    putStrLn "This line is also printed"
  let _ = nonbind
  let n = nonbind
  usleep 20000 -- Even if not explicitly awaited, we should let threads finish before exiting

map : IO ()
map = do
  future1 <- forkIO $ do
    usleep 10000
    putStrLn "#2"
  let future3 = map (const "#3") future1
  future2 <- forkIO $ do
    putStrLn "#1"
  pure $ await future2
  putStrLn (await future3)
