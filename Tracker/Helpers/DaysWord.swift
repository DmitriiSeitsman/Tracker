func daysWord(for count: Int) -> String {
    switch count % 10 {
    case 1 where count % 100 != 11: return "день"
    case 2...4 where !(12...14).contains(count % 100): return "дня"
    default: return "дней"
    }
}
