local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")
local gameLineCount = 30

local instructions = {
    'Type the word "bar" before the opening brackets and after the closing brackets.',
    'Use "va" and "%" to move to the brackets and between them respectively',
    "",
    "e.g.:",
    "[                    bar[       ",
    "   item1                item1",
    "   item2       -->      item2",
    "   item3                item3",
    "]                    ]bar",
    "",
}

local VaRound = {}
function VaRound:new(difficulty, window)
    log.info("New", difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
    }

    self.__index = self
    return setmetatable(round, self)
end

function VaRound:getInstructions()
    return instructions
end

function VaRound:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])
    self.config = {
        roundTime = GameUtils.difficultyToTime[self.difficulty],
    }

    return self.config
end

function VaRound:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local trimmed = GameUtils.trimLines(lines)

    log.info("VaRound:checkForWin", vim.inspect(trimmed))

    if #trimmed <= 1 then
        return false
    end

    winner = false
    local first_line = trimmed[1]
    local last_line = trimmed[#trimmed]
    if first_line == "bar[" and last_line == "]bar" then
        winner = true
        vim.cmd("stopinsert")
    end

    return winner
end

function VaRound:render()
    local lines = GameUtils.createEmpty(gameLineCount)
    local linesAfterInstructions = gameLineCount - #instructions
    local insertionIndex = GameUtils.getRandomInsertionLocation(gameLineCount, 6, #instructions)
    local goHigh = insertionIndex < gameLineCount / 2 and math.random() > 0.5

    local cursorIdx
    if goHigh then
        cursorIdx = math.random(math.floor(linesAfterInstructions / 2))
    else
        cursorIdx = math.random(math.floor(linesAfterInstructions / 2), linesAfterInstructions)
    end

    local sizeOfContainer = math.random(math.floor(linesAfterInstructions / 2))
    -- Minimum is three to include two lines for brackets and one line for at least one item
    lines[insertionIndex] = "["
    for idx = 1, sizeOfContainer do
        lines[insertionIndex + idx] = "   " .. GameUtils.getRandomWord() .. ","
    end
    lines[insertionIndex + sizeOfContainer] = "]"

    return lines, cursorIdx
end

function VaRound:name()
    return "va["
end

return VaRound
