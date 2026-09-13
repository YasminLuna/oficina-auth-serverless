def only_digits(value: str) -> str:
    return ''.join(ch for ch in value if ch.isdigit())


def is_valid_cpf(value: str) -> bool:
    cpf = only_digits(value)
    if len(cpf) != 11 or cpf == cpf[0] * 11:
        return False

    def digit(numbers: str, factor: int) -> int:
        total = sum(int(n) * f for n, f in zip(numbers, range(factor, 1, -1)))
        result = (total * 10) % 11
        return 0 if result == 10 else result

    return digit(cpf[:9], 10) == int(cpf[9]) and digit(cpf[:10], 11) == int(cpf[10])
