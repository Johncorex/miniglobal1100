local effects = {




	{position = Position(4157, 4085, 7), text = 'Reward', effect = CONST_ME_CRAPS},
	{position = Position(4154, 4087, 7), text = 'Roleta', effect = CONST_ME_YELLOWENERGY},
	{position = Position(4169, 4082, 7), text = 'NPCS', effect = CONST_ME_YELLOWENERGY},
	{position = Position(4161, 4085, 7), text = 'Hunts', effect = CONST_ME_YELLOWENERGY},
    {position = Position(4154, 4088, 7), text = 'Boss Event', effect = CONST_ME_HOLYDAMAGE},
	{position = Position(4137, 4066, 7), text = '[LOOT SELLER]', effect = CONST_ME_SOUND_YELLOW},
	{position = Position(4169, 4085, 7), text = 'Teleports', effect = CONST_ME_ASSASSIN},
	{position = Position(4161, 4082, 7), text = 'Dungeon', effect = CONST_ME_FERUMBRAS},
	{position = Position(4165, 4083, 7), text = '[Present]', effect = CONST_ME_HEARTS},
	{position = Position(4139, 4065, 7), text = '[+50% EXP BOOST]', effect = CONST_ME_HEARTS},

	---- EXITS
	{position = Position(4363, 4088, 6), text = 'EXIT', effect = CONST_ME_SOUND_YELLOW},
	{position = Position(5582, 4593, 6), text = 'EXIT', effect = CONST_ME_SOUND_YELLOW},
	{position = Position(4371, 4030, 7), text = 'EXIT', effect = CONST_ME_SOUND_YELLOW},
	{position = Position(4548, 4073, 7), text = 'EXIT', effect = CONST_ME_SOUND_YELLOW},
	

}

function onThink(interval)
    for i = 1, #effects do
        local settings = effects[i]
        local spectators = Game.getSpectators(settings.position, false, true, 7, 7, 5, 5)
        if #spectators > 0 then
            if settings.text then
                for i = 1, #spectators do
                    spectators[i]:say(settings.text, TALKTYPE_MONSTER_SAY, false, spectators[i], settings.position)
                end
            end
            if settings.effect then
                settings.position:sendMagicEffect(settings.effect)
            end
        end
    end
   return true
end
 