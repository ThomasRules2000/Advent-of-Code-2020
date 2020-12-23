{-# LANGUAGE ApplicativeDo   #-}
module Day7 where
  import Data.List.Split
  import Data.Char
  import Data.Map.Strict (Map)
  import qualified Data.Map.Strict as Map
  import Data.Set (Set)
  import qualified Data.Set as Set
  import Data.Sequence (Seq(..), (<|), (|>))
  import qualified Data.Sequence as Seq

  main :: IO ()
  main = do
    bags <- processTuples . map (listToTuple . splitOn " contain ") . lines <$> readFile "input.txt"
    print $ getNumAncestors bags bags (Seq.singleton "shiny gold") (Set.singleton "shiny gold")
    print $ getNumDecendants "shiny gold" $ Map.fromList bags

  listToTuple :: [a] -> (a, a)
  listToTuple [x,y] = (x,y)

  processTuples :: [(String, String)] -> [(String, Map String Int)]
  processTuples [] = []
  processTuples ((k,v):rest) = (removeBag k, Map.fromList $ getBagTuples v):processTuples rest

  getBagTuples :: String -> [(String, Int)]
  getBagTuples "no other bags." = []
  getBagTuples s = (map getTuple . splitOn ", " . init) s
    where
      getTuple :: String -> (String, Int)
      getTuple (num:space:bag) = (removeBag bag, digitToInt num)

  removeBag :: String -> String
  removeBag = unwords . init . words

  getNumAncestors :: [(String, Map String Int)] -> [(String, Map String Int)] -> Seq String -> Set String -> Int
  getNumAncestors _ _ Empty ancestors = Set.size ancestors - 1
  getNumAncestors [] full (y:<|ys) added = getNumAncestors full full ys added
  getNumAncestors ((bag, conts):xs) full curr@(c:<|_) added
    | Map.member c conts && Set.notMember bag added = getNumAncestors xs full (curr|>bag) (Set.insert bag added)
    | otherwise = getNumAncestors xs full curr added

  getNumDecendants :: String -> Map String (Map String Int) -> Int
  getNumDecendants bag m = sum $ map (\(newBag, num) -> num * (1 + getNumDecendants newBag m)) $ Map.toList $ m Map.! bag