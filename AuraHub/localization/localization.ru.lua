-- AuraHub — localization\localization.ru.lua
-- Russian overrides. Loaded after EN; only applied on ruRU clients.

if GetLocale() ~= "ruRU" then return end

local L = AuraHub.L

-- ── Core / static popups 
L["RELOAD_BODY"]        = "|cff4db8ffAuraHub|r\n\n%s\n\n|cffaaaaaaПерезагрузить интерфейс?|r"
L["RELOAD_NOW"]         = "Перезагрузить"
L["RELOAD_LATER"]       = "Позже"
L["SAVE_NAME_BODY"]     = "%s\n|cff888888Введите имя резервной копии:|r"
L["SAVE_NAME_DEFAULT"]  = "Бэкап %Y-%m-%d"
L["BTN_SAVE"]           = "Сохранить"
L["BTN_CANCEL"]         = "Отмена"
L["BTN_RESTORE"]        = "Загрузить"
L["BTN_GOT_IT"]         = "Понятно"
L["DELETE_BODY"]          = "Удалить |cffcccccc'%s'|r из AuraHub?\n|cff888888Действие необратимо.|r"
L["BTN_DELETE_CONFIRM"]   = "Удалить"
L["RESTORE_MACROS_BODY"]  = "Загрузить профиль макросов |cffcccccc'%s'|r?\n|cff888888Все текущие макросы будут заменены.|r"
L["BTN_RESTORE_CONFIRM"]  = "Загрузить"
L["ADDON_LOADED_MSG"]   = "v%s  •  /aurahub для открытия"
L["RESET_MSG"]          = "Все сохранённые данные удалены. Перезагрузите интерфейс."

-- ── Time ago 
L["TIME_JUST_NOW"]  = "только что"
L["TIME_AGO_MIN"]   = "%d мин. назад"
L["TIME_AGO_HOUR"]  = "%d ч. назад"
L["TIME_AGO_DAY"]   = "%d дн. назад"
L["TIME_UNKNOWN"]   = "неизвестно"

-- ── Plural word forms 
L["WORD_DISPLAY"]       = "дисплей"
L["WORD_DISPLAY_FEW"]   = "дисплея"
L["WORD_DISPLAYS"]      = "дисплеев"

L["WORD_BACKUP"]        = "бэкап"
L["WORD_BACKUP_FEW"]    = "бэкапа"
L["WORD_BACKUPS"]       = "бэкапов"

L["WORD_AURA"]          = "аура"
L["WORD_AURA_FEW"]      = "ауры"
L["WORD_AURAS"]         = "аур"

L["WORD_MACRO"]         = "макрос"
L["WORD_MACRO_FEW"]     = "макроса"
L["WORD_MACROS"]        = "макросов"

L["WORD_SLOT"]          = "слот"
L["WORD_SLOT_FEW"]      = "слота"
L["WORD_SLOTS"]         = "слотов"

-- ── WeakAuras page 
L["WA_TITLE"]            = "|cff4db8ffWeakAuras|r  — Бэкапы"
L["WA_BTN_SAVE"]         = "+ Сохранить WeakAura"
L["WA_BTN_SAVE_ALL"]     = "+ Сохранить все"
L["WA_BTN_RESTORE_ALL"]  = "Загрузить всё"
L["WA_BTN_CLEAR_ALL"]    = "Очистить всё"
L["WA_BTN_RESTORE_SEL"]  = "Загрузить (%d)"
L["WA_BTN_CLEAR_SEL"]   = "Сбросить"
L["WA_EMPTY"]            = "|cff333340Бэкапов WeakAura пока нет.\n\n|r" ..
                           "|cff404050Нажмите  |r|cff4db8ff+ Сохранить WeakAura|r" ..
                           "|cff404050  выше, чтобы создать бэкап.|r"
-- WA_META uses same format, word forms translated via WORD_* keys above
L["WA_SEARCH_HINT"]      = "Поиск..."
-- Picker dialog
L["WA_PICKER_TITLE"]         = "|cff4db8ffСохранить WeakAura|r"
L["WA_PICKER_NAME_LBL"]      = "|cff606065Имя:|r"
L["WA_PICKER_BTN_SAVE"]      = "Сохранить"
L["WA_PICKER_BTN_SAVE_ALL"]  = "Сохранить всё"
L["WA_PICKER_BTN_CANCEL"]    = "Отмена"
L["WA_STATUS_NO_WA"]         = "|cff663333WeakAura не найдены в базе данных.|r"
L["WA_STATUS_ALL_SAVED"]     = "|cff44aa44Все WeakAuras уже сохранены в AuraHub.|r"
L["WA_STATUS_FOUND"]         = "|cff404050%d %s найдено — выберите нужную|r"
-- Errors & messages
L["WA_ERR_NOT_READY"]    = "WeakAuras не загружен или база данных не готова."
L["WA_ERR_SELECT_FIRST"] = "Сначала выберите WeakAura из списка."
L["WA_ERR_ALREADY_SAVED"]= "'%s' уже сохранена."
L["WA_ERR_ENTER_NAME"]   = "Введите имя для бэкапа."
L["WA_ERR_CAPTURE_FAIL"] = "Ошибка захвата."
L["WA_ERR_NO_WA"]        = "WeakAura не найдены."
L["WA_ERR_NO_CAPTURES"]  = "Дисплеи не захвачены."
L["WA_PRINT_SAVED"]      = "'%s' сохранена."
L["WA_PRINT_ALL_SAVED"]  = "Сохранено %d WeakAuras."

-- ── ElvUI page 
L["ELVUI_TITLE"]          = "|cff4db8ffElvUI|r  — Бэкапы"
L["ELVUI_BTN_SAVE"]       = "+ Сохранить профиль ElvUI"
L["ELVUI_EMPTY"]          = "|cff333340Бэкапов ElvUI пока нет.\n\n|r" ..
                            "|cff404050Настройте интерфейс, затем нажмите  |r|cff4db8ff+ Сохранить профиль|r" ..
                            "|cff404050  выше.|r"
L["ELVUI_META"]           = "|cff353545Профиль ElvUI  ·  %s|r"
L["ELVUI_ERR_NOT_LOADED"] = "ElvUI не загружен."
L["ELVUI_ERR_DB"]         = "База данных ElvUI не готова."
L["ELVUI_ERR_DUPLICATE"]  = "Профиль '%s' уже сохранён."
L["ELVUI_PRINT_SAVED"]    = "Профиль ElvUI '%s' сохранён."

-- ── Skada page 
L["SKADA_TITLE"]          = "|cff4db8ffSkada|r  — Бэкапы"
L["SKADA_BTN_SAVE"]       = "+ Сохранить профиль Skada"
L["SKADA_EMPTY"]          = "|cff333340Бэкапов Skada пока нет.\n\n|r" ..
                            "|cff404050Настройте Skada, затем нажмите  |r|cff4db8ff+ Сохранить макет|r" ..
                            "|cff404050  выше.|r"
L["SKADA_META"]           = "|cff353545Макет Skada  ·  %s|r"
L["SKADA_ERR_NOT_LOADED"] = "Skada не загружен."
L["SKADA_ERR_DB"]         = "База данных Skada не готова."
L["SKADA_ERR_DUPLICATE"]  = "Профиль '%s' уже сохранён."
L["SKADA_PRINT_SAVED"]    = "Профиль Skada '%s' сохранён."

-- ── Binds page 
L["BINDS_TITLE"]          = "|cff4db8ffБинды|r  — Профили"
L["BINDS_BTN_SAVE"]       = "+ Сохранить бинды"
L["BINDS_EMPTY"]          = "|cff333340Профилей биндов пока нет.\n\n|r" ..
                            "|cff404050Настройте клавиши, затем нажмите  |r|cff4db8ff+ Сохранить бинды|r" ..
                            "|cff404050  выше.|r"
L["BINDS_META"]           = "|cff353545Бинды  ·  %s|r"
L["BINDS_POPUP_TITLE"]    = "Имя профиля биндов"
L["BINDS_ERR_DUPLICATE"]  = "Профиль '%s' уже сохранён."
L["BINDS_PRINT_SAVED"]    = "Бинды '%s' сохранены."

-- ── Macros page 
L["MACROS_TITLE"]         = "|cff4db8ffМакросы|r  — Профили"
L["MACROS_BTN_CHAR"]      = "+ Макросы персонажа"
L["MACROS_BTN_ALL"]       = "+ Все макросы"
L["MACROS_EMPTY"]         = "|cff333340Профилей макросов пока нет.\n\n|r" ..
                            "|cff404050Нажмите  |r|cff4db8ff+ Макросы персонажа|r|cff404050  или  |r" ..
                            "|cff4db8ff+ Все макросы|r|cff404050  выше.|r"
-- MACROS_META same format string as EN, word forms translated via WORD_MACRO*
L["MACROS_POPUP_CHAR"]    = "Макросы персонажа — имя профиля"
L["MACROS_POPUP_ALL"]     = "Все макросы — имя профиля"
L["MACROS_ERR_DUPLICATE"] = "Профиль '%s' уже сохранён."
L["MACROS_PRINT_SAVED"]      = "Макросы '%s' сохранены (%d)."
L["MACROS_BTN_RESTORE_SEL"] = "Загрузить (%d)"
L["MACROS_BTN_CLEAR_SEL"]   = "Сбросить"

-- ── ActionBars page
L["BARS_TITLE"]          = "|cff4db8ffБары|r  — Профили"
L["BARS_BTN_SAVE"]       = "+ Сохранить раскладку"
L["BARS_EMPTY"]          = "|cff333340Профилей раскладки панелей пока нет.\n\n|r" ..
                           "|cff404050Настрой панели действий, затем нажми  |r|cff4db8ff+ Сохранить раскладку|r" ..
                           "|cff404050  выше.|r"
L["BARS_POPUP_TITLE"]    = "Раскладка панелей — имя профиля"
L["BARS_ERR_DUPLICATE"]  = "Профиль '%s' уже сохранён."
L["BARS_PRINT_SAVED"]    = "Раскладка '%s' сохранена (%d слотов)."

-- ── Importer ─
L["IMP_WA_ERR_NOT_READY"]    = "WeakAuras не загружен или база данных не готова."
L["IMP_WA_ERR_NO_DISPLAYS"]  = "В записи нет данных дисплеев."
L["IMP_WA_ERR_NO_IDS"]       = "Дисплеи не восстановлены (отсутствует поле id)."
L["IMP_WA_RESTORED"]         = "'%s' записано в БД (%d %s). Перезагрузите интерфейс."
L["IMP_WA_RESTORED_PROMPT"]  = "'%s' восстановлено."
L["IMP_WA_SEL_RESTORED"]     = "%d %s восстановлено (%d %s). Перезагрузите интерфейс."
L["IMP_WA_SEL_PROMPT"]       = "%d %s WeakAura восстановлено."
L["IMP_WA_ALL_RESTORED"]     = "Все %d %s восстановлено (%d %s). Перезагрузите интерфейс."
L["IMP_WA_ALL_PROMPT"]       = "Все бэкапы WeakAura восстановлены."
L["IMP_WA_NO_BACKUPS"]       = "Нет бэкапов WeakAura для восстановления."
L["IMP_ELVUI_ERR_NOT_LOADED"]= "ElvUI не загружен."
L["IMP_ELVUI_ERR_DB"]        = "База данных ElvUI не готова."
L["IMP_ELVUI_ERR_NO_DATA"]   = "Нет данных для восстановления."
L["IMP_ELVUI_RESTORED"]      = "Профиль ElvUI '%s' восстановлен."
L["IMP_ELVUI_PROMPT"]        = "ElvUI '%s' восстановлен. Перезагрузите интерфейс."
L["IMP_SKADA_ERR_NOT_LOADED"]= "Skada не загружен."
L["IMP_SKADA_ERR_NO_DATA"]   = "Нет данных для восстановления."
L["IMP_SKADA_RESTORED"]      = "Профиль Skada '%s' восстановлен."
L["IMP_SKADA_PROMPT"]        = "Skada '%s' восстановлен. Перезагрузите интерфейс."
L["IMP_BINDS_ERR_NO_DATA"]   = "Нет данных для восстановления."
L["IMP_BINDS_RESTORED"]      = "Бинды '%s' восстановлены."
L["IMP_MACROS_ERR_NO_DATA"]  = "Нет данных для восстановления."
L["IMP_MACROS_RESTORED"]     = "Макросы '%s' восстановлены."
L["IMP_BARS_ERR_NO_DATA"]    = "Нет данных для восстановления."
L["IMP_BARS_ERR_COMBAT"]     = "Нельзя восстановить раскладку в бою."
L["IMP_BARS_RESTORED"]       = "Раскладка '%s' восстановлена (%d слотов)."

-- ── Main page ─
L["MAIN_SUBTITLE"]     = "|cff404050Менеджер резервных копий UI  ·  WoW 3.3.5a|r"
L["MAIN_HOW_WA"]       = "|cff4db8ff•|r |cffaaaaaa WeakAuras|r |cff505060— сохраняй ауры; восстанавливай в один клик|r"
L["MAIN_HOW_ELVUI"]    = "|cff4db8ff•|r |cffaaaaaa ElvUI|r     |cff505060— сохраняй профиль; восстанавливай в один клик|r"
L["MAIN_HOW_SKADA"]    = "|cff4db8ff•|r |cffaaaaaa Skada|r     |cff505060— сохраняй профиль; восстанавливай в один клик|r"
L["MAIN_HINT"]         = "|cff2a2a35Используй вкладки выше для сохранения и восстановления профилей.  " ..
                         "|r|cff4db8ffESC|r|cff2a2a35 — закрыть.|r"
L["MAIN_BTN_MULTI"]    = "Мультиаккаунт"
-- Summary card labels (only those that differ)
L["MAIN_SUM_KEYBINDS"] = "Бинды"
L["MAIN_SUM_MACROS"]   = "Макросы"
L["MAIN_SUM_BARS"]     = "Бары"
-- Sync dialog
L["SYNC_TITLE"]     = "|cff4db8ffМультиаккаунт|r  —  Синхронизация данных"
L["SYNC_HOW_TITLE"] = "|cff4db8ffКак это работает|r"
L["SYNC_HOW_TEXT"]  = "SyncAuraHub.bat копирует только файл AuraHub.lua\n" ..
                      "с одного аккаунта на все остальные.\n" ..
                      "Другие аддоны не затрагиваются."
L["SYNC_S1_TITLE"]  = "|cffe0e060Шаг 1|r  — Сохрани данные в игре"
L["SYNC_S1_TEXT"]   = "Зайди на аккаунт с нужными WeakAuras / профилями.\n" ..
                      "Убедись, что всё сохранено в AuraHub."
L["SYNC_S2_TITLE"]  = "|cffe0e060Шаг 2|r  — Выйди из игры"
L["SYNC_S2_TEXT"]   = "Полностью закрой WoW (не просто выбор персонажа).\n" ..
                      "WoW записывает SavedVariables только при полном выходе."
L["SYNC_S3_TITLE"]  = "|cffe0e060Шаг 3|r  — Запусти скрипт синхронизации"
L["SYNC_S3_TEXT"]   = "Найди этот файл в папке WoW и запусти его:"
L["SYNC_S3_TEXT2"]  = "Скрипт определит все аккаунты и спросит,\nс какого нужно копировать данные."
L["SYNC_S4_TITLE"]  = "|cffe0e060Шаг 4|r  — Зайди на любой аккаунт"
L["SYNC_S4_TEXT"]   = "Все твои WeakAuras, ElvUI и Skada бэкапы\nтеперь доступны на каждом аккаунте."
L["SYNC_REPEAT"]    = "|cff404050Повторяй шаги 1–3 при каждой смене аккаунта.|r"
L["SYNC_GOT_IT"]    = "Понятно"

-- ── Nav labels
L["NAV_HOME"]      = "Главная"
L["NAV_BINDS"]     = "Бинды"
L["NAV_MACROS"]    = "Макросы"
L["NAV_BARS"]      = "Бары"
L["NAV_HELP"]      = "Помощь"

-- ── Button widths
L["ELVUI_BTN_W"]    = 210
L["SKADA_BTN_W"]    = 210
L["WA_SAVE_BTN_W"]  = 165
L["WA_CLEAR_BTN_W"] = 120

-- ── Help page ─
L["HELP_BUG_REPORT"]         = "Если что-то работает некорректно (например, не загружается или не импортируется), пожалуйста, подробно опишите, при каких действиях возникла ошибка и что именно произошло. По всем вопросам и сообщениям об ошибках обращайтесь в Discord."
L["HELP_TITLE"]              = "|cff4db8ffAuraHub|r  — Помощь и информация"
L["HELP_FEAT_TITLE"]         = "|cff4db8ffФункции|r"
L["HELP_FEAT_KEYBINDS"]      = "Бинды"
L["HELP_FEAT_MACROS"]        = "Макросы"
L["HELP_FEAT_BARS"]          = "Бары"
L["HELP_FEAT_BARS_DESC"]     = "Сохраняет текущую раскладку панелей действий (бары 1–6, слоты 1–72). " ..
                               "При восстановлении заклинания и макросы расставляются по ID/имени. " ..
                               "Предметы — по возможности (нужны в сумке). В бою восстановление недоступно."
L["HELP_FEAT_MULTI"]         = "Мультиаккаунт"
L["HELP_FEAT_WA_DESC"]       = "Сохраняй именные бэкапы WeakAuras. На странице WeakAuras можно кликать по " ..
                               "картам аур для выбора (выделяются синим), затем использовать «Загрузить " ..
                               "выбранное» — удобно при смене специализации."
L["HELP_FEAT_ELVUI_DESC"]    = "Снимок всего профиля ElvUI. Имя профиля берётся автоматически. Удали старую " ..
                               "запись, если хочешь пересохранить после изменений."
L["HELP_FEAT_SKADA_DESC"]    = "Сохрани расположение окон Skada и настройки счётчика урона. Имя профиля " ..
                               "берётся автоматически."
L["HELP_FEAT_KEYBINDS_DESC"] = "Сохрани текущую раскладку клавиш под произвольным именем (напр. Танк, Хил, ДД). " ..
                               "При восстановлении биндинги применяются и сохраняются немедленно."
L["HELP_FEAT_MACROS_DESC"]   = "Сохрани макросы персонажа или все макросы (аккаунт + персонаж). При " ..
                               "восстановлении отсутствующие макросы создаются, существующие обновляются по имени."
L["HELP_FEAT_MULTI_DESC"]    = "Запусти SyncAuraHub.bat (в папке WoW), чтобы скопировать данные AuraHub " ..
                               "между всеми игровыми аккаунтами за один шаг."
L["HELP_QUEUE_TITLE"]        = "|cff4db8ffОчередь загрузки — применить всё сразу|r"
L["HELP_QUEUE_DESC"]         = "Вместо восстановления профилей по одному (с перезагрузкой каждый раз) можно " ..
                               "добавить несколько элементов в очередь и применить всё за одну перезагрузку.\n\n" ..
                               "|cffe0e060Как использовать:|r\n" ..
                               "1. Открой страницу WeakAuras, ElvUI или Skada.\n" ..
                               "2. Нажми кнопку |cff3a78cc+Q|r на каждой карте бэкапа.\n" ..
                               "3. Внизу появится синяя панель с очередью.\n" ..
                               "4. Нажми |cff2a7a2aПрименить и перезагрузить|r — все профили восстанавливаются, интерфейс перезагружается один раз."
