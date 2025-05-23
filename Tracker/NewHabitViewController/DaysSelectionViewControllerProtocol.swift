protocol DaysSelectionViewControllerDelegate: AnyObject {
    func didSelectWeekdays(_ weekdays: Set<Tracker.Weekday>)
}
