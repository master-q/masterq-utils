#!/usr/bin/env runhaskell
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS -Wall #-}
module Main where
import Prelude hiding (catch,lookup)
import Text.Parsec
import Text.Parsec.String
import System.Environment
import Control.Monad

data NicoItem = NicoItem {
  item_id :: Integer
  }

parseMylistPreload :: Parser String
parseMylistPreload = do
  void $ manyTill anyChar $ try (string "Mylist.preload(")
  void $ many1 digit
  void $ char ','
  void $ many space
  s <- manyTill anyChar $ try (string ");")
  void newline
  return s

stripParsedR :: Either ParseError String -> String
stripParsedR (Right a) = a
stripParsedR (Left pe) = error $ show pe

main :: IO ()
main = do
  args <- getArgs
  result <- parseFromFile parseMylistPreload $ head args
  let result' = stripParsedR result
  putStrLn result'

-- nicomylist-dl.hs top.html | aeson-pretty | grep watch_id |sed -e 's/.*\"watch_id\": \"/http:\/\/www.nicovideo.jp\/watch\//g'|sed -e 's/",//g' > tmp.list
-- for i in `cat tmp.list`; do nicovideo-dl -u xxx -p yyy $i; done
