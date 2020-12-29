port module Pages exposing (PathKey, allPages, allImages, internals, images, isValidRoute, pages, builtAt)

import Color exposing (Color)
import Pages.Internal
import Head
import Html exposing (Html)
import Json.Decode
import Json.Encode
import Pages.Platform
import Pages.Manifest exposing (DisplayMode, Orientation)
import Pages.Manifest.Category as Category exposing (Category)
import Url.Parser as Url exposing ((</>), s)
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Directory as Directory exposing (Directory)
import Time


builtAt : Time.Posix
builtAt =
    Time.millisToPosix 1609194544907


type PathKey
    = PathKey


buildImage : List String -> ImagePath.Dimensions -> ImagePath PathKey
buildImage path dimensions =
    ImagePath.build PathKey ("images" :: path) dimensions


buildPage : List String -> PagePath PathKey
buildPage path =
    PagePath.build PathKey path


directoryWithIndex : List String -> Directory PathKey Directory.WithIndex
directoryWithIndex path =
    Directory.withIndex PathKey allPages path


directoryWithoutIndex : List String -> Directory PathKey Directory.WithoutIndex
directoryWithoutIndex path =
    Directory.withoutIndex PathKey allPages path


port toJsPort : Json.Encode.Value -> Cmd msg

port fromJsPort : (Json.Decode.Value -> msg) -> Sub msg


internals : Pages.Internal.Internal PathKey
internals =
    { applicationType = Pages.Internal.Browser
    , toJsPort = toJsPort
    , fromJsPort = fromJsPort identity
    , content = content
    , pathKey = PathKey
    }




allPages : List (PagePath PathKey)
allPages =
    [ (buildPage [ "blog", "draft" ])
    , (buildPage [ "blog", "hello" ])
    , (buildPage [ "blog" ])
    , (buildPage [ "cv" ])
    , (buildPage [  ])
    ]

pages =
    { blog =
        { draft = (buildPage [ "blog", "draft" ])
        , hello = (buildPage [ "blog", "hello" ])
        , index = (buildPage [ "blog" ])
        , directory = directoryWithIndex ["blog"]
        }
    , cv = (buildPage [ "cv" ])
    , index = (buildPage [  ])
    , directory = directoryWithIndex []
    }

images =
    { articleCovers =
        { hello = (buildImage [ "article-covers", "hello.jpg" ] { width = 2000, height = 1561 })
        , mountains = (buildImage [ "article-covers", "mountains.jpg" ] { width = 2400, height = 1600 })
        , directory = directoryWithoutIndex ["articleCovers"]
        }
    , author =
        { dillon = (buildImage [ "author", "dillon.jpg" ] { width = 3035, height = 3035 })
        , raul = (buildImage [ "author", "raul.JPG" ] { width = 1080, height = 1920 })
        , directory = directoryWithoutIndex ["author"]
        }
    , elmLogo = (buildImage [ "elm-logo.svg" ] { width = 323, height = 323 })
    , github = (buildImage [ "github.svg" ] { width = 24, height = 24 })
    , icon = (buildImage [ "icon.svg" ] { width = 50, height = 75 })
    , iconPng = (buildImage [ "icon-png.png" ] { width = 50, height = 75 })
    , directory = directoryWithoutIndex []
    }


allImages : List (ImagePath PathKey)
allImages =
    [(buildImage [ "article-covers", "hello.jpg" ] { width = 2000, height = 1561 })
    , (buildImage [ "article-covers", "mountains.jpg" ] { width = 2400, height = 1600 })
    , (buildImage [ "author", "dillon.jpg" ] { width = 3035, height = 3035 })
    , (buildImage [ "author", "raul.JPG" ] { width = 1080, height = 1920 })
    , (buildImage [ "elm-logo.svg" ] { width = 323, height = 323 })
    , (buildImage [ "github.svg" ] { width = 24, height = 24 })
    , (buildImage [ "icon-png.png" ] { width = 50, height = 75 })
    , (buildImage [ "icon.svg" ] { width = 50, height = 75 })
    ]


isValidRoute : String -> Result String ()
isValidRoute route =
    let
        validRoutes =
            List.map PagePath.toString allPages
    in
    if
        (route |> String.startsWith "http://")
            || (route |> String.startsWith "https://")
            || (route |> String.startsWith "#")
            || (validRoutes |> List.member route)
    then
        Ok ()

    else
        ("Valid routes:\n"
            ++ String.join "\n\n" validRoutes
        )
            |> Err


content : List ( List String, { extension: String, frontMatter : String, body : Maybe String } )
content =
    [ 
  ( ["cv"]
    , { frontMatter = "{\"type\":\"blog\",\"author\":\"Fleischman Raul Andor\",\"title\":\"CV 🚀🚀🚀🚀\",\"description\":\"Here's an intro for my blog post to get you interested in reading more...\",\"image\":\"images/article-covers/hello.jpg\",\"published\":\"2021-01-01\"}"
    , body = Nothing
    , extension = "md"
    } )
  ,
  ( []
    , { frontMatter = "{\"title\":\"fra\",\"type\":\"page\"}"
    , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["blog", "draft"]
    , { frontMatter = "{\"type\":\"blog\",\"author\":\"Dillon Kearns\",\"title\":\"A Draft Blog Post\",\"description\":\"I'm not quite ready to share this post with the world\",\"image\":\"images/article-covers/mountains.jpg\",\"draft\":false,\"published\":\"2019-09-21\"}"
    , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["blog", "hello"]
    , { frontMatter = "{\"type\":\"blog\",\"author\":\"Dillon Kearns\",\"title\":\"Hello `elm-pages`! 🚀\",\"description\":\"Here's an intro for my blog post to get you interested in reading more...\",\"image\":\"images/article-covers/hello.jpg\",\"published\":\"2019-09-21\"}"
    , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["blog"]
    , { frontMatter = "{\"title\":\"elm-pages blog\",\"type\":\"blog-index\"}"
    , body = Nothing
    , extension = "md"
    } )
  
    ]
