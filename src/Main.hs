{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Yesod

data Test = Test
mkYesod "Test" [parseRoutes| / HomeR GET |]

instance Yesod Test

getHomeR :: Handler Html
getHomeR = defaultLayout $ do
  [whamlet|
    <h1>hello world from haskell!</h1>
  |]
  return ()

main = warp 4567 Test
