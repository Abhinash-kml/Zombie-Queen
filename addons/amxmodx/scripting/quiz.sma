#include <amxmodx>
#include <amxmisc>
#include <cstrike>

native AddPacks(id, amount)

#define MAX_QUESTIONS 200
#define MAX_NUM_OF_CHAR 190

new Questions[MAX_QUESTIONS][MAX_NUM_OF_CHAR]
new Answers[MAX_QUESTIONS][MAX_NUM_OF_CHAR]
new num_of_questions

new used_question[1][MAX_NUM_OF_CHAR]
new used_answer[1][MAX_NUM_OF_CHAR]

new answered_questions[32]

new bool:answered = false

new quiz_file[62]
new g_MyMsgSync

public plugin_init()
{
	register_plugin("Quiz System", "2.0", "Abhinash")
	
	register_clcmd("say", "OnSay")
	register_clcmd("say_team", "OnSay")
	
	new config[64]
	get_configsdir(config, charsmax(config))
	
	formatex(quiz_file, charsmax(quiz_file), "%s/quiz_file.ini", config)
	
	g_MyMsgSync = CreateHudSyncObj()

	if (!file_exists(quiz_file))
	{
		new file = fopen(quiz_file, "wt")
		fprintf(file, "; Quiz file^n")
		fprintf(file, "; Here goes all questions / answers^n")
		fprintf(file, "; Questions / Answers goes like ^"what is 1+1?^" ^"2^"^n")
		fclose(file)
	}

	LoadQuizFromFile()

	set_task(50.0, "SelectQuestion", .flags = "b")

	return PLUGIN_CONTINUE
}
	
public LoadQuizFromFile()
{
	new file = fopen(quiz_file, "rt")

	if (!file)
	{
		server_print("[NewlifeZM, LoadQuizFromFile()] Error, File not found!")
		return PLUGIN_HANDLED
	}

	new f_question[MAX_NUM_OF_CHAR], f_answer[MAX_NUM_OF_CHAR]

	new Text[MAX_NUM_OF_CHAR]

	while (!feof(file) && num_of_questions < MAX_QUESTIONS)
	{		
		fgets(file, Text, MAX_NUM_OF_CHAR-1)

		if (Text[0] == ';' || equal(Text, "")) continue;
		
		parse(Text, f_question, MAX_NUM_OF_CHAR-1, f_answer, MAX_NUM_OF_CHAR-1)
		
		num_of_questions++
		
		remove_quotes(f_answer)
		
		Questions[num_of_questions] = f_question
		Answers[num_of_questions] = f_answer
	}
	
	fclose(file)
	
	if (num_of_questions < 1)
	{
		server_print("[NewlifeZM] ERROR! You need more questions, you have %d, you need more then 2", num_of_questions)
		pause("ad")
	}
	
	server_print("[NewlifeZM] Successfully loaded %d questions", num_of_questions)
	
	return PLUGIN_HANDLED
}

public SelectQuestion()
{			
	new number = random_num(1, num_of_questions)
	
	copy(used_question[0], MAX_NUM_OF_CHAR - 1, Questions[number])
	copy(used_answer[0], MAX_NUM_OF_CHAR - 1, Answers[number])
	
	ShowQuestion()
	
	return PLUGIN_CONTINUE
}

public ShowQuestion()
{
	answered = false
	client_print_color(0, print_team_grey, "^4[NewlifeZM] ^1Question: ^3%s", used_question[0])
	
	//set_hudmessage(random(255), random(255), random(255), -1.0, 0.37, 0, 6.0, 7.0, 0.1, 0.2)
	//ShowSyncHudMsg(0, g_MyMsgSync, "Question: %s", used_question[0])

	set_task(25.0, "ShowTimeUp")
}

public ShowTimeUp()
{
	client_print_color(0, print_team_grey, "^4[NewlifeZM] ^1Time up, selecting new question...")
	
	//set_hudmessage(random(255), random(255), random(255), -1.0, 0.37, 0, 6.0, 7.0, 0.1, 0.2)
	//ShowSyncHudMsg(0, g_MyMsgSync, "Time up, selecting new question...")
}

public GiveReward(id)
{					
	static r; r = random_num(1, 50)
	static name[32]; get_user_name(id, name, charsmax(name))
	AddPacks(id, r)
	client_print_color(0, print_team_grey, "^4[NewlifeZM] ^3%s ^1got ^4%i ^1packs for solving the question...", name, r)
	//set_hudmessage(random(255), random(255), random(255), -1.0, 0.37, 0, 6.0, 7.0, 0.1, 0.2)
	//ShowSyncHudMsg(0, g_MyMsgSync, "%s got %i packs for solving the question...", name, r)
	
	return PLUGIN_CONTINUE
}

public OnSay(id)
{
	new arg[64]
	
	read_args(arg, charsmax(arg))
	
	if (contain(arg, used_answer[0]) != -1)
	{
		if (!answered)
		{
			answered_questions[id]++
			GiveReward(id)
			answered = true
		}
		
	}
	
	if (contain(arg, "/question") != -1) client_print_color(id, print_team_grey, "^4[NewlifeZM] ^1Question: ^3%s", used_question[0])
	  	
	return PLUGIN_CONTINUE
}