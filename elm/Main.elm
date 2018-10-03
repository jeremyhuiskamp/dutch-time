module Main exposing (dutchTimeSentence, main)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
import Svg exposing (..)
import Svg.Attributes exposing (..)


type alias Model =
    { hour : Int
    , minute : Int
    , showDutch : Bool
    }


initialModel : Model
initialModel =
    { hour = 1
    , minute = 30
    , showDutch = False
    }


type Msg
    = HideDutch
    | ShowDutch
    | RandomizeTime
    | SetTime ( Int, Int )


randomizeTime : Cmd Msg
randomizeTime =
    Random.generate SetTime <|
        Random.pair (Random.int 1 12) (Random.int 0 59)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HideDutch ->
            ( { model | showDutch = False }, Cmd.none )

        ShowDutch ->
            ( { model | showDutch = True }, Cmd.none )

        RandomizeTime ->
            ( model, randomizeTime )

        SetTime ( hour, minute ) ->
            ( { model | hour = hour, minute = minute }, Cmd.none )


dutchTimeSentence : Int -> Int -> String
dutchTimeSentence hour minute =
    let
        cardinals =
            Array.fromList
                [ "een"
                , "twee"
                , "drie"
                , "vier"
                , "vijf"
                , "zes"
                , "zeven"
                , "acht"
                , "negen"
                , "tien"
                , "elf"
                , "twaalf"
                , "dertien"
                , "veertien"
                ]

        cardinal num =
            Array.get (num - 1) cardinals
                |> Maybe.withDefault (toString num)

        nextHour =
            (hour % 12) + 1
    in
    if minute == 0 then
        cardinal hour ++ " uur"

    else if minute < 15 then
        cardinal minute ++ " over " ++ cardinal hour

    else if minute == 15 then
        "kwart over " ++ cardinal hour

    else if minute < 30 then
        cardinal (30 - minute) ++ " voor half " ++ cardinal nextHour

    else if minute == 30 then
        "half " ++ cardinal nextHour

    else if minute < 45 then
        cardinal (minute - 30) ++ " over half " ++ cardinal nextHour

    else if minute == 45 then
        "kwart voor " ++ cardinal nextHour

    else
        cardinal (60 - minute) ++ " voor " ++ cardinal nextHour


view : Model -> Html Msg
view model =
    let
        id =
            Html.Attributes.id

        text =
            Html.text

        style =
            Html.Attributes.style

        width =
            Svg.Attributes.width

        height =
            Svg.Attributes.height

        minuteHandDegrees =
            -- *6 because there are 60*6=360 degrees to rotate
            model.minute * 6

        hourHandDegrees =
            -- *30 because there are 12*30=360 degrees to rotate
            (toFloat model.hour + (toFloat model.minute / 60)) * 30

        ( dutchSentence, sentenceColour ) =
            if model.showDutch then
                ( "Het is " ++ dutchTimeSentence model.hour model.minute ++ ".", "black" )

            else
                ( "Hover to show dutch sentence.", "grey" )

        rotate : number -> Svg.Attribute Msg
        rotate degrees =
            transform ("rotate(" ++ toString degrees ++ ")")

        hand : Int -> Int -> String -> number -> Svg Msg
        hand length width colour degrees =
            line
                [ x1 "0"
                , y1 "0"
                , x2 "0"
                , y2 (toString (-1 * length))
                , strokeWidth (toString width ++ "px")
                , stroke colour
                , rotate degrees
                ]
                []

        clockTick : Int -> Svg Msg
        clockTick minute =
            let
                -- tweak size of ticks according to importance:
                ( y1_, y2_, width ) =
                    if minute % 60 == 0 then
                        ( "-98", "-90", "6px" )

                    else if minute % 15 == 0 then
                        ( "-99", "-90", "4px" )

                    else if minute % 5 == 0 then
                        ( "-100", "-90", "2px" )

                    else
                        ( "-100", "-93", "1px" )
            in
            g
                [ rotate (minute * 6) ]
                [ line
                    [ x1 "0"
                    , y1 y1_
                    , x2 "0"
                    , y2 y2_
                    , strokeWidth width
                    , stroke "black"
                    , strokeLinecap "round"
                    ]
                    []
                ]
    in
    div
        [ style [ ( "text-align", "center" ), ( "padding-top", "100px" ) ] ]
        [ h1 [] [ text "Hoe laat is het?" ]
        , svg
            [ width "220px", height "220px" ]
            [ g
                [ transform "translate(110, 110)" ]
                ([ circle
                    [ id "rim", r "106", strokeWidth "2px", fill "white", stroke "black" ]
                    []
                 , g [ id "hourhand" ] [ hand 70 3 "navy" hourHandDegrees ]
                 , g [ id "minutehand" ] [ hand 85 2 "green" minuteHandDegrees ]
                 , circle [ id "pin", r "4", fill "gold" ] []
                 ]
                    ++ (List.range 0 59 |> List.map clockTick)
                )
            ]
        , p []
            [ div
                [ id "dutchanswer"
                , onMouseOver ShowDutch
                , onMouseOut HideDutch
                , style [ ( "color", sentenceColour ) ]
                ]
                [ text dutchSentence ]
            ]
        , p []
            [ button [ onClick RandomizeTime ] [ text "random" ] ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, randomizeTime )
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }
