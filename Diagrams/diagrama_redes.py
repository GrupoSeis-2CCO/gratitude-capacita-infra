from diagrams import Diagram, Edge, Cluster
from diagrams.aws.network import InternetGateway, RouteTable, ELB
from diagrams.aws.general import User
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.storage import S3
from diagrams.custom import Custom
from diagrams.digitalocean.compute import Docker 
from diagrams.programming.language import Python
from diagrams.programming.language import Java
from diagrams.programming.framework import React
from diagrams.programming.framework import Spring
from diagrams.aws.management import Cloudwatch
from diagrams.aws.integration import SimpleNotificationServiceSns as SNS

with Diagram(
    "Diagrama de Rede Gratitude Capacita",
    direction="TB",
    graph_attr={"labelloc": "t",
                "fontsize": "36",
                "ranksep": "2.0",
                "nodesep": "1.0"
                }
    ):
    usuario1 = User("Funcionario")
    usuario2 = User("Colaborador")
    computador = Custom("Computador", "Diagrams/Icons/Computer.png")

    [usuario1, usuario2] << Edge(color="black") >> computador

    with Cluster("AWS", graph_attr={"bgcolor": "#ff910030"}):
        igw = InternetGateway("Internet Gateway")
        rt = RouteTable("Router Table")
        with Cluster("VPC", graph_attr={"bgcolor": "#262261A6", "color": "#ffffff"}):
            with Cluster("Sub-rede Privada", graph_attr={"bgcolor": "#0033ff60", "color": "#0d47a1"}):
                with Cluster("Zona de disponibilidade us-east-1a", graph_attr={"bgcolor": "#747474e0"}):
                    with Cluster("Security Group Privado 1"):
                        mysql = Custom("MySQL", "Diagrams/Icons/MySQL.png")
                        ec2_priv_02 = EC2("EC2 PRIV 02")
                    with Cluster("Security Group Privado 2"):
                        java = Java("Java")
                        spring = Spring("Spring")
                        ec2_priv_01 = EC2("EC2 PRIV 01")
            with Cluster("Sub-rede Pública", graph_attr={"bgcolor": "#26ff0060", "color": "#1b5e20"}):
                docker = Docker("Docker")
                with Cluster("Zona de disponibilidade us-east-1a", graph_attr={"bgcolor": "#747474e0"}):
                    with Cluster("Security Group Público"):
                        ec2_pub_01 = EC2("EC2 PUB 01")
                        react = React("React App")
                with Cluster("Zona de disponibilidade us-east-1b"):
                    with Cluster("Security Group Público"):
                        ec2_pub_02 = EC2("EC2 PUB 02")
                        react_icon = React("React App")
        with Cluster("Monitoramento", graph_attr={"bgcolor": "#e7157baa"}):
            cloudwatch = Cloudwatch("CloudWatch")
            sns = SNS("SNS")
        with Cluster("S3 e ETL", direction="LR"):
            bronze = S3("BRONZE")
            silver = S3("SILVER")
            gold = S3("GOLD")

            etl = Python("ETL Python")
            
            [ec2_pub_01, ec2_pub_02] >> Edge(color="black") >> bronze
            bronze >> Edge(color="gray") >> etl
            etl >> Edge(color="silver") >> silver
            silver >> Edge(color="silver") >> etl
            etl >> Edge(color="gold") >> gold

        lb = ELB("Load Balancer")

        computador << Edge(color="black", label="acesso a internet") >> igw
        igw << Edge(color="green") >> rt
        rt << Edge(color="green") >> lb
        rt << Edge(color="blue") >> lb

        
        lb << Edge(color="green") >> ec2_pub_01
        lb << Edge(color="green") >> ec2_pub_02
        rt << Edge(color="blue") >> ec2_priv_01
        rt << Edge(color="blue") >> ec2_priv_02

    