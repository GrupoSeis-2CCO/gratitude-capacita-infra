# EFS para compartilhamento de arquivos
resource "aws_efs_file_system" "gratitude_efs" {
  creation_token = "gratitude-efs"
  tags = {
    Name = "gratitude-efs"
  }
}

resource "aws_efs_mount_target" "gratitude_efs_publica" {
  file_system_id  = aws_efs_file_system.gratitude_efs.id
  subnet_id       = aws_subnet.subrede_publica_gratitude.id
  security_groups = [aws_security_group.sg_publica_gratitude.id]
}

resource "aws_efs_mount_target" "gratitude_efs_publica2" {
  file_system_id  = aws_efs_file_system.gratitude_efs.id
  subnet_id       = aws_subnet.subrede_publica2_gratitude.id
  security_groups = [aws_security_group.sg_publica_gratitude.id]
}
