all:
	mix escript.build

clean:
	mix clean

fclean: clean
	rm -rf computer_v1 _build

re: fclean all
