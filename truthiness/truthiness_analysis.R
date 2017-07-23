library(statsr)
library(dplyr)
library(shiny)
library(ggplot2)
library(RPostgreSQL)
library(reshape2)


##Connect to local PostgreSQL database

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "postgres",
                 host = "localhost", port = 5432,
                 user = "postgres")


#############################################
## STATEMENT RATINGS TRUE/FALSE BY PARTY
#############################################

party_truthiness_sql ="select date,party, case when ruling in ('False','Mostly False','Pants on Fire!') then 'False' when ruling in ('True','Mostly True') then 'True' else ruling end as true_false from truthiness
order by date desc"

truthiness_df <- dbGetQuery(con, party_truthiness)

truthiness_df <- truthiness_df[truthiness_df$party %in% c("Democrat", "Republican", "Independent"),]
truthiness_df <- truthiness_df[truthiness_df$true_false %in% c("False", "True", "Half-True"),]

truthiness_stats <- truthiness_df %>%
  group_by(party,true_false) %>%
  summarise(n=n()) %>%
  group_by(party) %>%
  mutate(pct=100*n/sum(n))

truthiness_stats$label_pct = round(truthiness_stats$pct,digits=2)

ggplot(truthiness_stats,aes(x=party,y=pct,fill=true_false))  +
  geom_bar(stat="identity", width=.5, position = "dodge") +
  geom_text(aes(label=label_pct), vjust=1.5, position=position_dodge(.5), size=4)

#############################################
## PANTS ON FIRE!
#############################################

pants_on_fire_sql ="select * from truthiness where ruling ='Pants on Fire!'"

pants_on_fire_df <- dbGetQuery(con, pants_on_fire_sql)

pants_on_fire_counts <- pants_on_fire_df %>%
  group_by(name) %>%
  summarise(n=n())

pants_on_fire_counts <- pants_on_fire_counts[pants_on_fire_counts$n > 3,]

ggplot(pants_on_fire_counts, aes(x=n, y=reorder(name, n),color=n)) + 
  geom_point() + 
  #geom_text(aes(label=n),position=position_dodge(.8)) +
  geom_segment(aes(yend=name), xend=0, color='grey50') +
  ggtitle("Total 'Pants on Fire!' statements by person/organization") +
  labs(x='Count',y='Name')

#############################################################  
## STATEMENT RATINGS BY PERSON/ORGANIZATION OVER TIME
#############################################################

truthiness_sql ="select date,name,ruling from truthiness"

truthiness_df <- dbGetQuery(con, truthiness_sql)

truthiness_df$true = as.numeric(truthiness_df$ruling=='True' | truthiness_df$ruling=='Mostly True')
truthiness_df$false = as.numeric(truthiness_df$ruling=='False' | truthiness_df$ruling=='Mostly False' | truthiness_df$ruling=='Pants on Fire!')
truthiness_df$half_true = as.numeric(truthiness_df$ruling=='Half-True')

truthiness_df[order(as.Date(truthiness_df$date, format="%d/%m/%Y")),]

truthiness_stats <- truthiness_df %>%
  group_by(name) %>%
  arrange(date) %>%
  mutate(total = seq(n())) %>%
  mutate(true_cumsum=cumsum(true)/total) %>%
  mutate(false_cumsum=cumsum(false)/total) %>%
  mutate(half_true_cumsum=cumsum(half_true)/total)

truthiness_stats <- truthiness_stats[,c("date","name","true_cumsum","false_cumsum","half_true_cumsum")]

truthiness_stats_long <- melt(truthiness_stats, id.vars = c("date","name"))

filter = "Hillary Clinton"

truthiness_stats_filter <- truthiness_stats_long[truthiness_stats_long$name == filter,]

ggplot(truthiness_stats_filter,aes(y=value,x=date,colour=variable)) + 
  geom_point() + geom_smooth()