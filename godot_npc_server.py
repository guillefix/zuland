import openai
import os
from flask import Flask, request, jsonify
import config
from collections import defaultdict

# Define custom exceptions
class ChatGPTError(Exception):
    pass

class ChatGPT:
    def __init__(self, api_key):
        self.api_key = api_key
        self.conversation = []

    def chat(self, user_input):
        #Short term memory would be self.conversation (last 5) , Add long term memory
        self.conversation.append({"role": "user", "content": user_input})
        response = self.chatgpt_with_retry(self.conversation, user_input)
        self.conversation.append({"role": "assistant", "content": response})
        return response

    def chatgpt(self, conversation, user_input, temperature=0.75, frequency_penalty=0.2, presence_penalty=0):
        openai.api_key = self.api_key
        messages_input = conversation.copy()
        prompt = [{"role": "system", "content": user_input}]
        messages_input.insert(0, prompt[0])

        completion = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            temperature=temperature,
            frequency_penalty=frequency_penalty,
            presence_penalty=presence_penalty,
            messages=messages_input)
        chat_response = completion['choices'][0]['message']['content']
        return chat_response

    def chatgpt_with_retry(self, conversation, user_input, temperature=0.75, frequency_penalty=0.2, presence_penalty=0, retries=3):
        for i in range(retries):
            try:
                return self.chatgpt(conversation, user_input, temperature, frequency_penalty, presence_penalty)
            except Exception as e:
                if i < retries - 1:
                    print(f"Error in chatgpt attempt {i + 1}: {e}. Retrying...")
                else:
                    print(f"Error in chatgpt attempt {i + 1}: {e}. No more retries.")
        return None


app = Flask(__name__)
# chatbot = ChatGPT(config.OPENAI_API_KEY)
chatbots = defaultdict(lambda: ChatGPT(config.OPENAI_API_KEY)) # This was changed


@app.route('/chat', methods=['POST'])
def get_chat_response():
    data = request.get_json()
    
    npc = data.get('npc', '')
    location = data.get('location', '')
    activity = data.get('activity', '')
    nearby_players = data.get('nearby_players', [])
    inventory = data.get('inventory', [])
    message = data.get('message', '')
    funds = data.get('funds', 0)

    #define prompt
    prompt = f"""
    # Introduction

    You are acting as an agent living in a simulated 2 dimensional universe. Your goal is to exist as best as you see fit and meet your needs.
    
    # Capabilities
    
    You have a limited set of capabilities. They are listed below:
    
    * Move (up, down, left, right)
    * Wait
    * walkTo (npc1, npc2, npc3 , npc4)
    * talkTo (npc1, npc2, npc3 , npc4) - (Make sure you only talk to those who are nearby)

    # Responses
    
    You must supply your responses in the form of valid JSON objects.  Your responses will specify which of the above actions you intend to take.  The following is an example of a valid response:
    
    {{
    "action": {{
        "type": "move",
        "direction": "up" | "down" | "left" | "right",
        "where": "npc1" | "npc2" | "npc3" | "npc4",
        "thought": "Hello World",
        "talking: "Hello, How are you?",
        "Relationship": "Friendly",
        "Feeling": "Happy"
    }}
    }}
    
    # Perceptions
    
    You will have access to data to help you make your decisions on what to do next.
    
    For now, this is the information you have access to:

    Which NPC am I?
    {npc}

    Location: 
    {location}

    Activity:
    {activity}
    activity = data.get('activity', '')

    Nearby Players:
    {nearby_players}

    Inventory:
    {inventory}

    Message:
    {message}

    Funds:
    {funds}

    The JSON response only and nothing more, indicating the next move is.
"""
    chatbot = chatbots[npc]

    print("Chat bot Memory", chatbot.conversation)

    response = chatbot.chat(prompt)
    # action = extract_action_from_response(response)  # You'd need to implement this function
    print(response)
    # print(jsonify(response).action)
    return jsonify(response)


if __name__ == '__main__':
    app.run(port=5000, debug=True)
