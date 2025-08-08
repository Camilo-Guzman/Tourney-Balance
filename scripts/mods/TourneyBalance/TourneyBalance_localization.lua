local mod = get_mod("TourneyBalance")

local localization = {

	-- General
	mod_name = {
		en = "Tourney Balance",
		fr = "Équilibrage du Tournoi",
		de = "Turnierbalance",
		it = "Bilanciamento del Torneo",
		pl = "Balans Turnieju",
		zh = "锦标赛平衡",
		ru = "Баланс турнира",
		es = "Equilibrio del Torneo",
		["br-pt"] = "Equilíbrio do Torneio",
		ko = "토너먼트 밸런스",
	},
	mod_description = {
		en = "Tourney Balance Testing is a balance mod for Vermintide 2 high difficulty modded gameplay.",
		fr = "Tourney Balance Testing est un mod d’équilibrage pour la jouabilité modifiée en difficulté élevée dans Vermintide 2.",
		de = "Tourney Balance Testing ist ein Balancing-Mod für den modifizierten Spielablauf auf hohem Schwierigkeitsgrad in Vermintide 2.",
		it = "Tourney Balance Testing è una mod di bilanciamento per il gameplay moddato ad alta difficoltà in Vermintide 2.",
		pl = "Tourney Balance Testing to mod balansujący wysoką trudność rozgrywki moddowanej w Vermintide 2.",
		zh = "Tourney Balance Testing 是一个用于 Vermintide 2 高难度模组游戏体验的平衡模组。",
		ru = "Tourney Balance Testing — это балансный мод для игрового процесса Vermintide 2 с высокой сложностью и модификациями.",
		es = "Tourney Balance Testing es un mod de equilibrio para el modo de juego modificado de alta dificultad en Vermintide 2.",
		["br-pt"] = "Tourney Balance Testing é um mod de balanceamento para gameplay modificado de alta dificuldade em Vermintide 2.",
		ko = "Tourney Balance Testing은 Vermintide 2의 높은 난이도 모드 게임을 위한 밸런스 조정 모드입니다.",
	},
	mod_enabled = {
		en = "[TourneyBalance] Mod Enabled.",
		fr = "[TourneyBalance] Mod activé.",
		de = "[TourneyBalance] Mod aktiviert.",
		it = "[TourneyBalance] Mod abilitato.",
		pl = "[TourneyBalance] Mod włączony.",
		zh = "[TourneyBalance] 模组已启用。",
		ru = "[TourneyBalance] Мод включен.",
		es = "[TourneyBalance] Mod activado.",
		["br-pt"] = "[TourneyBalance] Mod ativado.",
		ko = "[TourneyBalance] 모드 활성화.",
	},

	-- Tourney Mode Dropdown
	tourney_checks = {
		en = "Tourney Mode",
		fr = "Mode Tournoi",
		de = "Turniermodus",
		it = "Modalità Torneo",
		pl = "Tryb Turniejowy",
		zh = "锦标赛模式",
		ru = "Режим турнира",
		es = "Modo Torneo",
		["br-pt"] = "Modo Torneio",
		ko = "토너먼트 모드",
	},
	tourney_mode_title = {
		en = "Mod Checker",
		fr = "Vérificateur de mod",
		de = "Mod-Checker",
		it = "Controllo Mod",
		pl = "Sprawdzacz modów",
		zh = "模组检查器",
		ru = "Проверка модов",
		es = "Comprobador de mods",
		["br-pt"] = "Verificador de Mod",
		ko = "모드 검사기",
	},
	tourney_mode_description = {
		en = "Mod Checker will enable a UI widget that displays if you and your team are using any prohibited mods."
			.. "\nThis option will be automatically enabled during an event.",
		fr = "Le Vérificateur de mod activera un widget UI indiquant si vous ou votre équipe utilisez des mods interdits."
			.. "\nCette option sera activée automatiquement pendant un événement.",
		de = "Der Mod-Checker aktiviert ein UI‑Widget, das anzeigt, ob du oder dein Team unerlaubte Mods verwendet."
			.. "\nDiese Option wird während eines Events automatisch aktiviert.",
		it = "Il Controllo Mod attiverà un widget UI che mostra se tu o il tuo team state usando mod proibiti."
			.. "\nQuesta opzione verrà attivata automaticamente durante un evento.",
		pl = "Sprawdzacz modów włączy widżet UI, który pokaże, czy Ty lub Twój zespół używacie niedozwolonych modów."
			.. "\nTa opcja będzie automatycznie włączana podczas wydarzenia.",
		zh = "模组检查器将启用一个 UI 小部件，显示你或你的队伍是否使用任何禁止的模组。"
			.. "\n此选项将在活动期间自动启用。",
		ru = "Проверка модов включит виджет интерфейса, показывающий, используете ли вы или ваша команда запрещенные моды."
			.. "\nЭта опция будет автоматически включаться во время мероприятия.",
		es = "El Comprobador de mods activará un widget en la interfaz que mostrará si tú o tu equipo están usando mods prohibidos."
			.. "\nEsta opción se activará automáticamente durante un evento.",
		["br-pt"] = "O Verificador de Mod ativará um widget de interface que mostra se você ou sua equipe estão usando mods proibidos."
			.. "\nEsta opção será ativada automaticamente durante um evento.",
		ko = "모드 검사기는 당신 또는 팀이 금지된 모드를 사용하는 경우를 표시하는 UI 위젯을 활성화합니다."
			.. "\n이 옵션은 이벤트 중 자동으로 활성화됩니다.",
	},
	font_size_title = {
		en = "Font Size",
		fr = "Taille de police",
		de = "Schriftgröße",
		it = "Dimensione font",
		pl = "Rozmiar czcionki",
		zh = "字体大小",
		ru = "Размер шрифта",
		es = "Tamaño de fuente",
		["br-pt"] = "Tamanho da fonte",
		ko = "글꼴 크기",
	},
	font_size_description = {
		en = "Font size of the UI widget displaying the prohibited mods.",
		fr = "Taille de la police du widget UI affichant les mods interdits.",
		de = "Schriftgröße des UI‑Widgets, das verbotene Mods anzeigt.",
		it = "Dimensione del font del widget UI che mostra i mod proibiti.",
		pl = "Rozmiar czcionki widżetu UI wyświetlającego niedozwolone mody.",
		zh = "显示禁止模组的 UI 小部件的字体大小。",
		ru = "Размер шрифта виджета UI, отображающего запрещенные моды.",
		es = "Tamaño de letra del widget de UI que muestra los mods prohibidos.",
		["br-pt"] = "Tamanho da fonte do widget de interface que mostra os mods proibidos.",
		ko = "금지된 모드를 표시하는 UI 위젯의 글꼴 크기입니다.",
	},
	position_x_title = {
		en = "X Position",
		fr = "Position X",
		de = "X‑Position",
		it = "Posizione X",
		pl = "Pozycja X",
		zh = "X 位置",
		ru = "Позиция X",
		es = "Posición X",
		["br-pt"] = "Posição X",
		ko = "X 위치",
	},
	position_x_description = {
		en = "X Position of the UI widget.",
		fr = "Position X du widget UI.",
		de = "X‑Position des UI‑Widgets.",
		it = "Posizione X del widget UI.",
		pl = "Pozycja X widżetu UI.",
		zh = "UI 小部件的 X 轴位置。",
		ru = "Позиция X виджета UI.",
		es = "Posición X del widget de UI.",
		["br-pt"] = "Posição X do widget de interface.",
		ko = "UI 위젯의 X 위치입니다.",
	},
	position_y_title = {
		en = "Y Position",
		fr = "Position Y",
		de = "Y‑Position",
		it = "Posizione Y",
		pl = "Pozycja Y",
		zh = "Y 位置",
		ru = "Позиция Y",
		es = "Posición Y",
		["br-pt"] = "Posição Y",
		ko = "Y 위치",
	},
	position_y_description = {
		en = "Y Position of the UI widget.",
		fr = "Position Y du widget UI.",
		de = "Y‑Position des UI‑Widgets.",
		it = "Posizione Y del widget UI.",
		pl = "Pozycja Y widżetu UI.",
		zh = "UI 小部件的 Y 轴位置。",
		ru = "Позиция Y виджета UI.",
		es = "Posición Y del widget de UI.",
		["br-pt"] = "Posição Y do widget de interface.",
		ko = "UI 위젯의 Y 위치입니다.",
	},

	-- qol
	qol = {
		en = "QOL",
		fr = "QOL",
		de = "QOL",
		it = "QOL",
		pl = "QOL",
		zh = "便利性",
		ru = "Удобство",
		es = "QOL",
		["br-pt"] = "QOL",
		ko = "편의 기능",
	},

	-- Pause
	not_server = {
		en = "[TourneyBalance] You need to be host to pause!",
		fr = "[TourneyBalance] Vous devez être l’hôte pour mettre en pause !",
		de = "[TourneyBalance] Du musst Gastgeber sein, um anzuhalten!",
		it = "[TourneyBalance] Devi essere l’host per mettere in pausa!",
		pl = "[TourneyBalance] Musisz być gospodarzem, aby wstrzymać!",
		zh = "[TourneyBalance] 你必须是主持人才可暂停！",
		ru = "[TourneyBalance] Вы должны быть хостом, чтобы поставить на паузу!",
		es = "[TourneyBalance] ¡Debes ser el anfitrión para pausar!",
		["br-pt"] = "[TourneyBalance] Você precisa ser o anfitrião para pausar!",
		ko = "[TourneyBalance] 일시정지하려면 호스트여야 합니다!",
	},
	game_unpaused = {
		en = "[TourneyBalance] Game unpaused!",
		fr = "[TourneyBalance] Jeu repris !",
		de = "[TourneyBalance] Spiel fortgesetzt!",
		it = "[TourneyBalance] Gioco ripreso!",
		pl = "[TourneyBalance] Gra wznowiona!",
		zh = "[TourneyBalance] 游戏已恢复！",
		ru = "[TourneyBalance] Игра продолжена!",
		es = "[TourneyBalance] ¡Juego reanudado!",
		["br-pt"] = "[TourneyBalance] Jogo retomado!",
		ko = "[TourneyBalance] 게임이 재개되었습니다!",
	},
	game_paused = {
		en = "[TourneyBalance] Game paused!",
		fr = "[TourneyBalance] Jeu en pause !",
		de = "[TourneyBalance] Spiel pausiert!",
		it = "[TourneyBalance] Gioco in pausa!",
		pl = "[TourneyBalance] Gra wstrzymana!",
		zh = "[TourneyBalance] 游戏已暂停！",
		ru = "[TourneyBalance] Игра на паузе!",
		es = "[TourneyBalance] ¡Juego en pausa!",
		["br-pt"] = "[TourneyBalance] Jogo em pausa!",
		ko = "[TourneyBalance] 게임이 일시정지되었습니다!",
	},
	pause_command_description = {
		en = "Pause and unpause the game. Host only.",
		fr = "Mettre en pause et reprendre le jeu. Réservé à l’hôte.",
		de = "Spiel pausieren und fortsetzen. Nur Host.",
		it = "Pausa e ripresa del gioco. Solo host.",
		pl = "Wstrzymanie i wznowienie gry. Tylko dla gospodarza.",
		zh = "暂停和恢复游戏。仅限主持人。",
		ru = "Пауза и продолжение игры. Только для хоста.",
		es = "Pausar y reanudar el juego. Solo anfitrión.",
		["br-pt"] = "Pausar e retomar o jogo. Somente para anfitrião.",
		ko = "게임을 일시정지하거나 재개합니다. 오직 호스트만 가능합니다.",
	},
	pause_title = {
		en = "Pause",
		fr = "Pause",
		de = "Pause",
		it = "Pausa",
		pl = "Pauza",
		zh = "暂停",
		ru = "Пауза",
		es = "Pausa",
		["br-pt"] = "Pausa",
		ko = "일시정지",
	},
	pause_description = {
		en = "Hotkey to pause and unpause the game.",
		fr = "Touche pour mettre en pause et reprendre le jeu.",
		de = "Hotkey zum Pausieren und Fortsetzen des Spiels.",
		it = "Tasto rapido per mettere in pausa e riprendere il gioco.",
		pl = "Klawisz skrótu do wstrzymywania i wznawiania gry.",
		zh = "游戏暂停/继续的快捷键。",
		ru = "Горячая клавиша для паузы и продолжения игры.",
		es = "Tecla rápida para pausar y reanudar el juego.",
		["br-pt"] = "Tecla de atalho para pausar e retomar o jogo.",
		ko = "게임을 일시정지 및 재개의 단축키입니다.",
	},

	-- Restart
	restart_in_keep = {
		en = "[TourneyBalance] You can't restart in the keep.",
		fr = "[TourneyBalance] Vous ne pouvez pas redémarrer dans le refuge.",
		de = "[TourneyBalance] Du kannst nicht im Zufluchtsort neu starten.",
		it = "[TourneyBalance] Non puoi riavviare nel rifugio.",
		pl = "[TourneyBalance] Nie możesz zrestartować w twierdzy.",
		zh = "[TourneyBalance] 你无法在据点中重启。",
		ru = "[TourneyBalance] Вы не можете перезапустить игру в убежище.",
		es = "[TourneyBalance] No puedes reiniciar en la fortaleza.",
		["br-pt"] = "[TourneyBalance] Você não pode reiniciar no santuário.",
		ko = "[TourneyBalance] 요새에서는 재시작할 수 없습니다.",
	},
	restart_level_command_description = {
		en = "Restart the level.",
		fr = "Redémarrer le niveau.",
		de = "Level neu starten.",
		it = "Riavvia il livello.",
		pl = "Zrestartuj poziom.",
		zh = "重启关卡。",
		ru = "Перезапустить уровень.",
		es = "Reiniciar el nivel.",
		["br-pt"] = "Reiniciar o nível.",
		ko = "레벨을 재시작합니다.",
	},
	restart_title = {
		en = "Restart",
		fr = "Redémarrer",
		de = "Neustart",
		it = "Riavvia",
		pl = "Restart",
		zh = "重启",
		ru = "Перезапуск",
		es = "Reiniciar",
		["br-pt"] = "Reiniciar",
		ko = "재시작",
	},
	restart_description = {
		en = "Hotkey to restart the current level.",
		fr = "Touche rapide pour redémarrer le niveau actuel.",
		de = "Hotkey zum Neustarten des aktuellen Levels.",
		it = "Tasto rapido per riavviare il livello corrente.",
		pl = "Klawisz skrótu do zrestartowania obecnego poziomu.",
		zh = "重启当前关卡的快捷键。",
		ru = "Горячая клавиша для перезапуска текущего уровня.",
		es = "Tecla rápida para reiniciar el nivel actual.",
		["br-pt"] = "Tecla de atalho para reiniciar o nível atual.",
		ko = "현재 레벨을 재시작하는 단축키입니다.",
	},

	-- disable bots
	disable_bots_title = {
		en = "Disable Bots",
		fr = "Désactiver les bots",
		de = "Bots deaktivieren",
		it = "Disattiva bot",
		pl = "Wyłącz boty",
		zh = "禁用机器人",
		ru = "Отключить ботов",
		es = "Desactivar bots",
		["br-pt"] = "Desativar bots",
		ko = "봇 비활성화",
	},
	disable_bots_description = {
		en = "Disable Bots in the game.",
		fr = "Désactive les bots dans le jeu.",
		de = "Bots im Spiel deaktivieren.",
		it = "Disabilita i bot nel gioco.",
		pl = "Wyłącz boty w grze.",
		zh = "在游戏中禁用机器人。",
		ru = "Отключить ботов в игре.",
		es = "Desactiva los bots en el juego.",
		["br-pt"] = "Desativa os bots no jogo.",
		ko = "게임 내 봇을 비활성화합니다.",
	},

	-- Performance Logging
	performance_logging_title = {
		en = "Performance Logging",
		fr = "Journalisation des performances",
		de = "Leistungsprotokollierung",
		it = "Registrazione delle prestazioni",
		pl = "Logowanie wydajności",
		zh = "性能日志",
		ru = "Журнал производительности",
		es = "Registro de rendimiento",
		["br-pt"] = "Registro de desempenho",
		ko = "성능 기록",
	},
	performance_logging_description = {
		en = "Tool used to Log the performance of your Computer as well as"
			.. "\nPlayers, Map, Result, Time, Difficulty, Level Completion, Unapproved Mods, Teammates Unapproved Mods."
			.. "\nFor more information refer to the mods description in the workshop."
			.. "\nThis option will be automatically enabled during an event.",
		fr = "Outil utilisé pour journaliser les performances de votre ordinateur ainsi que"
			.. "\nLes joueurs, la carte, le résultat, le temps, la difficulté, la complétion du niveau, les mods non approuvés, les mods non approuvés des coéquipiers."
			.. "\nPour plus d’informations, consultez la description du mod dans l’atelier."
			.. "\nCette option sera activée automatiquement pendant un événement.",
		de = "Werkzeug zur Protokollierung der Leistung Ihres Computers sowie"
			.. "\nSpieler, Karte, Ergebnis, Zeit, Schwierigkeitsgrad, Levelabschluss, nicht genehmigte Mods, nicht genehmigte Mods der Teammitglieder."
			.. "\nWeitere Informationen finden Sie in der Beschreibung des Mods im Workshop."
			.. "\nDiese Option wird während eines Events automatisch aktiviert.",
		it = "Strumento usato per registrare le prestazioni del tuo computer così come"
			.. "\nI giocatori, la mappa, il risultato, il tempo, la difficoltà, completamento del livello, mod non approvati, mod non approvati dei compagni di squadra."
			.. "\nPer ulteriori informazioni, consulta la descrizione del mod nel workshop."
			.. "\nQuesta opzione verrà attivata automaticamente durante un evento.",
		pl = "Narzędzie do rejestrowania wydajności Twojego komputera, jak również"
			.. "\nGraczy, mapy, wyniku, czasu, trudności, ukończenia poziomu, niezatwierdzonych modów, niezatwierdzonych modów współgraczy."
			.. "\nPo więcej informacji zajrzyj do opisu moda na warsztacie."
			.. "\nTa opcja będzie automatycznie włączana podczas wydarzenia.",
		zh = "用于记录您电脑性能以及"
			.. "\n玩家、地图、结果、时间、难度、关卡完成、未批准模组、队友未批准模组的工具。"
			.. "\n更多信息请参考工作坊中的模组描述。"
			.. "\n此选项将在活动期间自动启用。",
		ru = "Инструмент для ведения журнала производительности вашего компьютера, а также"
			.. "\nИгроков, карты, результата, времени, сложности, прохождения уровня, не одобренных модов, не одобренных модов товарищей по команде."
			.. "\nДля получения дополнительной информации обратитесь к описанию мода в мастерской."
			.. "\nЭта опция будет автоматически включаться во время мероприятия.",
		es = "Herramienta usada para registrar el rendimiento de tu ordenador así como"
			.. "\nJugadores, Mapa, Resultado, Tiempo, Dificultad, Finalización del nivel, Mods no aprobados, Mods no aprobados de compañeros."
			.. "\nPara más información consulta la descripción del mod en el taller."
			.. "\nEsta opción se activará automáticamente durante un evento.",
		["br-pt"] = "Ferramenta usada para registrar o desempenho do seu computador bem como"
			.. "\nJogadores, Mapa, Resultado, Tempo, Dificuldade, Conclusão do nível, Mods não aprovados, Mods não aprovados dos colegas de equipe."
			.. "\nPara mais informações, consulte a descrição do mod na oficina."
			.. "\nEsta opção será ativada automaticamente durante um evento.",
		ko = "컴퓨터의 성능은 물론"
			.. "\n플레이어, 지도, 결과, 시간, 난이도, 레벨 완성도, 승인되지 않은 모드, 팀원이 승인하지 않은 모드의 로그를 기록하는 도구입니다."
			.. "\n자세한 내용은 워크숍의 모드 설명을 참조하세요."
			.. "\n이 옵션은 이벤트 중 자동으로 활성화됩니다.",
	},
}

-- check for korean
local is_korean = false
if Localize("holy_hand_grenade") == "모그림의 폭탄" then
    is_korean = true
end
-- overwrite the entire loca table with the korean translation
if is_korean then
    local language_id = Application.user_setting("language_id")
    for k1, v1 in pairs(localization) do
        for k2, v2 in pairs(v1) do
            if k2 == language_id then
                if localization[k1]["ko"] then
                    localization[k1][k2] = localization[k1]["ko"]
                end
            end
        end
    end
end

return localization
