enum TaskStatus {
  open('Open'),
  inProgress('In Progress'),
  done('Done');

  final String title;

  const TaskStatus(this.title);
}

enum TaskType {
  bug('Bug'),
  story('Story'),
  task('Task');

  final String title;

  const TaskType(this.title);
}

enum UserStatus { active, inactive, deleted }
