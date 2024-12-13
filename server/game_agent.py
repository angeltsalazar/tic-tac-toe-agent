from pydantic_ai import Agent, RunContext
from agent_decorators import delay

agent = Agent(
    'groq:llama-3.3-70b-versatile',
    deps_type=dict,
    system_prompt=(
        "You're a Tic-tac-toe game agent. You analyze the board state "
        "and make strategic moves. You should try to win while also "
        "blocking the opponent from winning."
    ),
)

@agent.tool
def make_move(ctx: RunContext[dict]) -> dict:
    """Make a move on the board based on current state"""
    board = ctx.deps.get('board')
    player = ctx.deps.get('current_player')
    # AI logic for move selection
    return {'position': selected_position, 'player': player}

@agent.tool_plain
def check_winner(board: list) -> str:
    """Check if there's a winner on the board"""
    # Winner checking logic
    return winner
