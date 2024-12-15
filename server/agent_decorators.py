from functools import wraps
import time

def delay(seconds):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            nonlocal last_call
            elapsed_time = time.time() - last_call
            remaining_time = seconds - elapsed_time

            if remaining_time > 0:
                time.sleep(remaining_time)

            last_call = time.time()
            return func(*args, **kwargs)
        
        last_call = 0 # Initializar el tiempo de la ultima llamada
        return wrapper
    return decorator

if __name__ == "__main__":
    @delay(seconds=10)
    def my_function(name):
        print(f"Hola, {name}! Tiempo actual: {time.time()}")

    my_function("Alice")  # Primera llamada, se ejecuta inmediatamente
    time.sleep(5)
    my_function("Bob")    # Segunda llamada, espera 5 segundos
    time.sleep(12)
    my_function("Charlie") # Tercera llamada, se ejecuta inmediatamente