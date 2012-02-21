#!/usr/bin/env runhaskell
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS -Wall #-}
module Main where
import Prelude hiding (catch,lookup)
import Text.Parsec
import Text.Parsec.String
import System.Environment
import Control.Monad
import qualified Data.Aeson as A
import qualified Data.Aeson.Types as AT
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC8
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString.Lazy.Char8 as BLC8

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
